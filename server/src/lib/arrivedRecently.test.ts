import { assertEquals } from "../deps.ts"
import { isArmedDoorbellAction } from "./arrivedRecently.ts"

const getTime = () => new Date().getTime() / 1000

Deno.test("isArmedDoorbellAction - null", () => {
  assertEquals(isArmedDoorbellAction(null), false)
})
Deno.test("isArmedDoorbellAction - past", () => {
  assertEquals(
    isArmedDoorbellAction({ type: "buzzer", timeout: getTime() - 10 }),
    false
  )
})

Deno.test("isArmedDoorbellAction - future", () => {
  assertEquals(
    isArmedDoorbellAction({ type: "buzzer", timeout: getTime() + 10 }),
    true
  )
})
