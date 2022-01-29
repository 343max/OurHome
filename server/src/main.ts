import { findUser } from "./lib/user.ts"
import { getNukiDeviceStatus } from "./lib/nuki.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader, verifyAuth } from "./lib/auth.ts"
import { Action } from "./lib/action.ts"

import {
  Application,
  Context,
  HandlerFunc,
} from "https://deno.land/x/abc@v1.3.3/mod.ts"

const app = new Application()

const authorized =
  (action: Action, handler: (c: Context) => Promise<any> | any): HandlerFunc =>
  async (c) => {
    if (verifyAuth(c.request.headers.get("Authorization"), action, "remote")) {
      c.response.headers.append(
        "content-type",
        "application/json; charset=UTF-8"
      )
      return JSON.stringify(await handler(c))
    } else {
      c.response.status = 403
    }
  }

if (getRuntimeConfig().ignoreAuthentication) {
  console.log(
    "⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️"
  )
}

const port = 4278
console.log(`🌳 server running at http://localhost:${port}/ 🌳`)

app
  .post(
    "/buzzer",
    authorized("buzzer", async () => {
      await fetch(configuration.buzzerUrl)
      return { success: true }
    })
  )
  .get(
    "/user",
    authorized("user", ({ request }) => {
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
    "/state",
    authorized("state", async () => {
      const nukiState = await getNukiDeviceStatus(configuration.nuki)
      return { success: true, doorlock: nukiState }
    })
  )
  .start({ port })
