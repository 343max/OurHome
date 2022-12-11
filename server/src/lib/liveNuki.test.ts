import { assertEquals } from "../deps.ts"
import { getNukiUrl } from "./liveNuki.ts"

Deno.test("generate url", () => {
  const url = getNukiUrl(
    "lock",
    {
      host: "my-nuki.local",
      port: 8080,
      token: "1234",
      deviceId: 5,
    },
    {}
  )
  assertEquals(url, "http://my-nuki.local:8080/lock?token=1234&nukiId=5")
})

Deno.test("generate url with additional parameters", () => {
  const url = getNukiUrl(
    "lock",
    {
      host: "my-nuki.local",
      port: 8080,
      token: "1234",
      deviceId: 5,
    },
    { action: 42, name: "lockylock" }
  )
  assertEquals(
    url,
    "http://my-nuki.local:8080/lock?token=1234&nukiId=5&action=42&name=lockylock"
  )
})
