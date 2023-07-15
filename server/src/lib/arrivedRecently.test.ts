import { expect, test } from "bun:test"
import { isArmedDoorbellAction } from "./arrivedRecently.ts"

const getTime = () => new Date().getTime() / 1000

test("isArmedDoorbellAction - null", () => {
  expect(isArmedDoorbellAction(null)).toBeFalse()
})
test("isArmedDoorbellAction - past", () => {
  expect(
    isArmedDoorbellAction({ type: "buzzer", timeout: getTime() - 10 })
  ).toBeFalse()
})

test("isArmedDoorbellAction - future", () => {
  expect(
    isArmedDoorbellAction({ type: "buzzer", timeout: getTime() + 10 })
  ).toBeTrue()
})
