import { dumpInviteLinks, findUser } from "./lib/user.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader, verifyAuth } from "./lib/auth.ts"
import {
  getCurrentDoorbellAction,
  resetDoorBellAction,
  armForDoorBellAction,
} from "./lib/arrivedRecently.ts"
import { buildInfo } from "./lib/buildinfo.ts"
import express, { RequestHandler } from "express"
import {
  pushNotificationRegistration,
  pushNotificationController,
} from "./lib/pushNotifications"
import { actionForPath } from "./lib/action"
import { env } from "./lib/env.ts"

const app = express()

const authorized = (
  path: string,
  handler: RequestHandler
): [string, RequestHandler] => {
  const action = actionForPath(path)
  if (action === undefined) {
    throw new Error(`unknown action for path ${path}`)
  }
  return [
    path,
    async (req, res, next) => {
      const authHeader = req.header("Authorization")
      const externHeader = req.header("x-forwarded-for")
      if (
        verifyAuth(
          authHeader,
          action,
          externHeader === undefined ? "local" : "remote"
        )
      ) {
        res.contentType("application/json; charset=UTF-8")
        await handler(req, res, next)
      } else {
        console.log("unauthorized")
        res.status(403)
        res.send({ success: false })
      }
    },
  ]
}

if (getRuntimeConfig().ignoreAuthentication) {
  console.log(
    "⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️"
  )
}

const port = 4278

console.log(`🌳 server running at http://localhost:${port}/ 🌳`)
console.log(`👷 build date: ${buildInfo.date}`)

dumpInviteLinks()

const {
  registerDevice,
  removeDevice,
  sendPush,
  getDoorbellRingSubscribers,
  getWhenOtherUserArrivesSubscribers,
} = pushNotificationController(env.DEVICE_TOKEN_DB_PATH)

const pressBuzzer = async () => {
  for (const _ in [0, 1, 2, 3, 4, 5]) {
    await Bun.sleep(500)
    await configuration.buzzer.pressBuzzer()
  }
}

const handleError =
  <R>(
    fn: (...args: Parameters<RequestHandler>) => Promise<R>
  ): RequestHandler =>
  async (req, res, next) => {
    try {
      res.send(await fn(req, res, next))
    } catch (error) {
      console.error(error)
      res.send({
        success: false,
        error: JSON.stringify(error, Object.getOwnPropertyNames(error)),
      })
    }
  }

app
  .use(express.json())
  .all("*", (req, res, next) => {
    console.log(`🌎 ${req.ip} ${req.method} ${req.url}`)
    next()
  })
  .post(
    ...authorized("/buzzer", async (req, res) => {
      await pressBuzzer()
      res.send({ success: true })
    })
  )
  .post(
    ...authorized(
      "/lock",
      handleError(() => configuration.nuki.lock())
    )
  )
  .post(
    ...authorized(
      "/unlock",
      handleError(() => configuration.nuki.unlock())
    )
  )
  .post(
    ...authorized(
      "/unlatch",
      handleError(() => configuration.nuki.unlatch())
    )
  )
  .get(
    ...authorized("/user", (req, res) => {
      const authHeader = splitAuthHeader(req.headers.authorization)
      if (authHeader === null) {
        res.send({ sucess: false })
        return
      }
      const { secret: _secret, ...userInfo } = findUser(authHeader.username)!
      res.send({ success: true, userInfo })
    })
  )
  .get(
    ...authorized(
      "/state",
      handleError(async () => ({
        success: true,
        doorlock: await configuration.nuki.getState(),
        doorbellAction: getCurrentDoorbellAction(),
      }))
    )
  )
  .post(
    ...authorized("/arrived", (req, res) => {
      armForDoorBellAction("buzzer", configuration.arrivalTimeout)
      res.send({ success: true })
    })
  )
  .post(
    ...authorized("/arm/buzzer", (req, res) => {
      armForDoorBellAction("buzzer", configuration.buzzerArmTimeout)
      res.send({ success: true })
    })
  )
  .post(
    ...authorized("/arm/unlatch", (req, res) => {
      armForDoorBellAction("unlatch", configuration.unlatchArmTimeout)
      res.send({ success: true })
    })
  )
  .post("/doorbell", async (req, res, next) => {
    const action = getCurrentDoorbellAction()
    if (action === null) {
      // if it wasn't one of us, send a notification
      sendPush("🔔 Ding! Dong!", getDoorbellRingSubscribers())

      console.log("doorbell action not armed, doing nothing")
      res.send({ success: false })
      return
    }

    switch (action.type) {
      case "buzzer":
        console.log("buzzer because the doorbell buzzer was armed")
        await pressBuzzer()
        await Bun.sleep(500)
        resetDoorBellAction()
        res.send({ success: true })
      case "unlatch":
        console.log("unlatching because the doorbell buzzer was armed")
        resetDoorBellAction()
        await handleError(() => configuration.nuki.unlatch())(req, res, next)
    }
  })
  .put(
    ...authorized(
      "/pushnotifications/:deviceToken",
      handleError(async (req) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        const { types } = pushNotificationRegistration.parse(req.body)
        registerDevice(username, req.params.deviceToken, types)
        console.log([username, req.params.deviceToken, types])
        return { success: true }
      })
    )
  )
  .delete(
    ...authorized(
      "/pushnotifications/:deviceToken",
      handleError(async (req, res) => {
        removeDevice(req.params.deviceToken)
        return { success: true }
      })
    )
  )
  .get("/", (req, res) =>
    res.send({ success: true, message: "please leave me alone" })
  )
  .head("/", (req, res) =>
    res.send({ success: true, message: "please leave me alone" })
  )
  .listen(port)
