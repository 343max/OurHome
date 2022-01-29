import { assertEquals } from "https://deno.land/std@0.123.0/testing/asserts.ts"
import { getNukiUrl } from "./nuki.ts"
Deno.test("generate url", () => {
  const url = getNukiUrl("list", {
    host: "my-nuki.local",
    port: 8080,
    token: "1234",
  })
  assertEquals(url, "http://my-nuki.local:8080/list?token=1234")
})
