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
import { sleep } from "https://deno.land/x/sleep/mod.ts"

import {
  Application,
  Context,
  HandlerFunc,
} from "https://deno.land/x/abc@v1.3.3/mod.ts"

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
      return JSON.stringify(await handler(c))
    } else {
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

Deno.run({
  cmd: ["autossh", "-R 4278:localhost:4278", "max@343max.de"],
  stdin: "null",
  stdout: "null",
})

app
  .post(
    ...authorized("buzzer", async () => {
      for (const i in [0, 1, 2, 3, 4, 5]) {
        await sleep(0.5)
        await fetch(configuration.buzzerUrl)
      }
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
  .start({ port })
