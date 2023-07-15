import { expect, test } from "bun:test"
import { getNukiUrl } from "./liveNuki.ts"

test("generate url", () => {
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
  expect(url).toBe("http://my-nuki.local:8080/lock?token=1234&nukiId=5")
})

test("generate url with additional parameters", () => {
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
  expect(url).toBe(
    "http://my-nuki.local:8080/lock?token=1234&nukiId=5&action=42&name=lockylock"
  )
})
