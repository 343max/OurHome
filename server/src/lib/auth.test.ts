import {
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.123.0/testing/asserts.ts"
import {
  accessAllowed,
  getAuthHeader,
  getToken,
  splitAuthHeader,
} from "./auth.ts"

Deno.test("authHeader", () => {
  const authHeader = getAuthHeader("max", "abcdef", "lock", 4223)
  assertEquals(
    authHeader,
    "max:n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=:4223"
  )
})

Deno.test("make sure different params create different headers", () => {
  const authHeader = getToken("max", "abcdef", "lock", 4223)
  assertNotEquals(authHeader, getToken("max", "abcdef", "lock", 123))
  assertNotEquals(authHeader, getToken("not max", "abcdef", "lock", 4223))
  assertNotEquals(authHeader, getToken("max", "other secret", "lock", 4223))
  assertNotEquals(authHeader, getToken("max", "abcdef", "unlatch", 4223))
})

Deno.test("check actions", () => {
  assertEquals(accessAllowed("full", "local"), true)
  assertEquals(accessAllowed("full", "remote"), true)
  assertEquals(accessAllowed("local", "local"), true)
  assertEquals(accessAllowed("local", "remote"), false)
  assertEquals(accessAllowed("none", "local"), false)
  assertEquals(accessAllowed("none", "remote"), false)
})

Deno.test("split auth header", () => {
  const { username, token, timestamp } = splitAuthHeader(
    "max:n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=:4223"
  )!

  assertEquals(username, "max")
  assertEquals(token, "n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=")
  assertEquals(timestamp, 4223)

  assertEquals(splitAuthHeader(""), null)
})
