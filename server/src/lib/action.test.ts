import { expect, test } from "bun:test"
import { actionForPath } from "./action"

test("actions", () => {
  expect(actionForPath("/pushnotifications/:deviceid")).toBe(
    "/pushnotifications"
  )
})
