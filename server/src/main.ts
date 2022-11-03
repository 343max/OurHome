import { findUser } from "./lib/user.ts"
import {
  getNukiLockConfig,
  nukiLock,
  nukiUnlatch,
  nukiUnlock,
} from "./lib/nuki.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader, verifyAuth } from "./lib/auth.ts"
import { Action } from "./lib/action.ts"
import { Application, Context, HandlerFunc, sleep } from "./deps.ts"
import {
  getArrivedRecently,
  resetArrival,
  setArrivedNow,
} from "./lib/arrivedRecently.ts"

const app = new Application()

const authorized = (
  action: Action,
  // deno-lint-ignore no-explicit-any
  handler: (c: Context) => Promise<any> | any,
  allowExternal = false
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
      console.log(resp)
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

const pressBuzzer = async () => {
  for (const _ in [0, 1, 2, 3, 4, 5]) {
    await sleep(0.5)
    await fetch(configuration.buzzerUrl)
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
  .post(...authorized("lock", async () => await nukiLock(configuration.nuki)))
  .post(
    ...authorized("unlock", async () => await nukiUnlock(configuration.nuki))
  )
  .post(
    ...authorized("unlatch", async () => await nukiUnlatch(configuration.nuki))
  )
  .get(
    ...authorized("user", ({ request }) => {
      const authHeader = splitAuthHeader(request.headers.get("Authorization"))
      if (authHeader === null) {
        return { sucess: false }
      }
      // deno-lint-ignore no-unused-vars
      const { secret, ...userInfo } = findUser(authHeader.username)!
      return { success: true, userInfo }
    })
  )
  .get(
    ...authorized("state", async () => {
      const nukiState = await getNukiLockConfig(configuration.nuki)
      return { success: true, doorlock: nukiState }
    })
  )
  .post(
    ...authorized("arrived", () => {
      setArrivedNow()
      return { success: true }
    })
  )
  .post("doorbell", async () => {
    if (getArrivedRecently()) {
      await pressBuzzer()
      await sleep(0.5)
      resetArrival()
      return { success: true }
    } else {
      return { sucess: false }
    }
  })
  .get("/", () => ({ success: true, message: "please leave me alone" }))
  .start({ port })
