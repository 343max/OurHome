import {
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.123.0/testing/asserts.ts"
import { accessAllowed, getAuthHeader } from "./auth.ts"

Deno.test("authHeader", () => {
  const authHeader = getAuthHeader("max", "abcdef", "lock", 4223)
  assertEquals(
    authHeader,
    "max/iMai2Pyi17bnMR8yCmzi7Mwf+iHVioMysuBFjr3/QoQ=/4223"
  )
})

Deno.test("make sure different params create different headers", () => {
  const authHeader = getAuthHeader("max", "abcdef", "lock", 4223).split("/")[1]
  assertNotEquals(
    authHeader,
    getAuthHeader("max", "abcdef", "lock", 123).split("/")[1]
  )
  assertNotEquals(
    authHeader,
    getAuthHeader("not max", "abcdef", "lock", 4223).split("/")[1]
  )
  assertNotEquals(
    authHeader,
    getAuthHeader("max", "other secret", "lock", 4223).split("/")[1]
  )
  assertNotEquals(
    authHeader,
    getAuthHeader("max", "abcdef", "unlatch", 4223).split("/")[1]
  )
})

Deno.test("check actions", () => {
  assertEquals(accessAllowed("full", "local"), true)
  assertEquals(accessAllowed("full", "remote"), true)
  assertEquals(accessAllowed("local", "local"), true)
  assertEquals(accessAllowed("local", "remote"), false)
  assertEquals(accessAllowed("none", "local"), false)
  assertEquals(accessAllowed("none", "remote"), false)
})
