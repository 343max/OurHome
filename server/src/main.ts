import { dumpInviteLinks, findUser } from "./lib/user.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader, verifyAuth } from "./lib/auth.ts"
import { Action } from "./lib/action.ts"
import { Application, Context, HandlerFunc, sleep } from "./deps.ts"
import {
  getCurrentDoorbellAction,
  resetDoorBellAction,
  armForDoorBellAction,
} from "./lib/arrivedRecently.ts"
import { buildInfo } from "./lib/buildinfo.ts"

const app = new Application()

const authorized = (
  action: Action,
  handler: (c: Context) => Promise<unknown> | unknown
): [string, HandlerFunc] => [
  `/${action}`,
  async (c) => {
    const authHeader = c.request.headers.get("Authorization")
    const externHeader = c.request.headers.get("X-External-Host")
    if (
      verifyAuth(authHeader, action, externHeader === null ? "local" : "remote")
    ) {
      c.response.headers.append(
        "content-type",
        "application/json; charset=UTF-8"
      )
      const resp = JSON.stringify(await handler(c))
      console.log(`response: ${resp}`)
      return resp
    } else {
      console.log("unauthorized")
      c.response.status = 403
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
    await sleep(0.5)
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
  .pre((next) => (c) => {
    console.log(
      `🌎 ${
        c.request.conn.remoteAddr.transport === "tcp"
          ? c.request.conn.remoteAddr.hostname
          : "???"
      } ${c.request.method} ${c.request.url}`
    )
    return next(c)
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
    ...authorized("user", ({ request }) => {
      const authHeader = splitAuthHeader(request.headers.get("Authorization"))
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
      armForDoorBellAction("buzzer")
      return { success: true }
    })
  )
  .post(
    ...authorized("arm/buzzer", () => {
      armForDoorBellAction("buzzer")
      return { success: true }
    })
  )
  .post(
    ...authorized("arm/unlatch", () => {
      armForDoorBellAction("unlatch")
      return { success: true }
    })
  )
  .post("doorbell", async () => {
    const action = getCurrentDoorbellAction()
    if (action === null) {
      console.log("doorbell action not armed, doing nothing")
      return { sucess: false }
    }

    switch (action.type) {
      case "buzzer":
        await pressBuzzer()
        await sleep(0.5)
        resetDoorBellAction()
        return { success: true }
      case "unlatch":
        console.log("unlatching door")
        resetDoorBellAction()
        return await handleError(() => configuration.nuki.unlatch())()
    }
  })
  .get("/", () => ({ success: true, message: "please leave me alone" }))
  .head("/", () => ({ success: true, message: "please leave me alone" }))
  .start({ port })
