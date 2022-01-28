import { configuration } from "./secrets.ts"
import { verifyAuth } from "./lib/auth.ts"
import { Action } from "./lib/action.ts"

import {
  Application,
  Context,
  HandlerFunc,
} from "https://deno.land/x/abc@v1.3.3/mod.ts"

const app = new Application()

const authorized =
  (
    action: Action,
    handler: (c: Context) => Promise<unknown> | unknown
  ): HandlerFunc =>
  (c) => {
    if (verifyAuth(c.request.headers.get("Authorization"), action, "remote")) {
      return handler(c)
    } else {
      c.response.status = 403
    }
  }

const port = 4278
console.log(`🌳 server running at http://localhost:${port}/ 🌳`)

app
  .post(
    "/buzzer",
    authorized("buzzer", async () => {
      await fetch(configuration.buzzerUrl)
    })
  )
  .get("/", () => "hello!")
  .start({ port })
