import { dumpInviteLinks, findUser } from "./lib/user.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader, verifyAuth } from "./lib/auth.ts"
import { Action } from "./lib/action.ts"
import {
  getCurrentDoorbellAction,
  resetDoorBellAction,
  armForDoorBellAction,
} from "./lib/arrivedRecently.ts"
import { buildInfo } from "./lib/buildinfo.ts"
import { sendNotification } from "./lib/ntfy.ts"
import express, { RequestHandler } from "express"

const app = express()

const authorized = (
  action: Action,
  handler: RequestHandler
): [string, RequestHandler] => [
  `/${action}`,
  async (req, res, next) => {
    const authHeader = req.headers.authorization
    const externHeader = req.headers["X-External-Host"]
    if (
      verifyAuth(
        authHeader,
        action,
        externHeader === undefined ? "local" : "remote"
      )
    ) {
      res.contentType("application/json; charset=UTF-8")
      const resp = JSON.stringify(await handler(req, res, next))
      console.log(`response: ${resp}`)
      return resp
    } else {
      console.log("unauthorized")
      res.status(403)
    }
  },
]

if (getRuntimeConfig().ignoreAuthentication) {
  console.log(
    "⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️"
  )
}

const port = 4278

console.log(`🌳 server running at http://localhost:${port}/ 🌳`)
console.log(`👷 build date: ${buildInfo.date}`)

dumpInviteLinks()

const pressBuzzer = async () => {
  for (const _ in [0, 1, 2, 3, 4, 5]) {
    await Bun.sleep(500)
    await configuration.buzzer.pressBuzzer()
  }
}

const handleError =
  <R>(
    fn: () => Promise<R>
  ): (() => Promise<R | { success: false; error: string }>) =>
  async () => {
    try {
      return await fn()
    } catch (error) {
      return {
        success: false,
        error: JSON.stringify(error, Object.getOwnPropertyNames(error)),
      }
    }
  }

app
  .all("*", (req, res, next) => {
    console.log(`🌎 ${req.ip} ${req.method} ${req.url}`)
    next()
  })
  .post(
    ...authorized("buzzer", async () => {
      await pressBuzzer()
      return { success: true }
    })
  )
  .post(
    ...authorized(
      "lock",
      handleError(() => configuration.nuki.lock())
    )
  )
  .post(
    ...authorized(
      "unlock",
      handleError(() => configuration.nuki.unlock())
    )
  )
  .post(
    ...authorized(
      "unlatch",
      handleError(() => configuration.nuki.unlatch())
    )
  )
  .get(
    ...authorized("user", (req) => {
      const authHeader = splitAuthHeader(req.headers.authorization)
      if (authHeader === null) {
        return { sucess: false }
      }
      const { secret: _secret, ...userInfo } = findUser(authHeader.username)!
      return { success: true, userInfo }
    })
  )
  .get(
    ...authorized(
      "state",
      handleError(async () => ({
        success: true,
        doorlock: await configuration.nuki.getState(),
        doorbellAction: getCurrentDoorbellAction(),
      }))
    )
  )
  .post(
    ...authorized("arrived", () => {
      armForDoorBellAction("buzzer", configuration.arrivalTimeout)
      return { success: true }
    })
  )
  .post(
    ...authorized("arm/buzzer", () => {
      armForDoorBellAction("buzzer", configuration.buzzerArmTimeout)
      return { success: true }
    })
  )
  .post(
    ...authorized("arm/unlatch", () => {
      armForDoorBellAction("unlatch", configuration.unlatchArmTimeout)
      return { success: true }
    })
  )
  .post("doorbell", async () => {
    const action = getCurrentDoorbellAction()
    if (action === null) {
      // if it wasn't one of us, send a notification
      if (configuration.doorbellNtfy !== null) {
        sendNotification("🔔 Ding! Dong!", configuration.doorbellNtfy)
      }

      console.log("doorbell action not armed, doing nothing")
      return { sucess: false }
    }

    switch (action.type) {
      case "buzzer":
        console.log("buzzer because the doorbell buzzer was armed")
        await pressBuzzer()
        await Bun.sleep(500)
        resetDoorBellAction()
        return { success: true }
      case "unlatch":
        console.log("unlatching because the doorbell buzzer was armed")
        resetDoorBellAction()
        return await handleError(() => configuration.nuki.unlatch())()
    }
  })
  .get("/", () => ({ success: true, message: "please leave me alone" }))
  .head("/", () => ({ success: true, message: "please leave me alone" }))
  .listen(port)
