import { expect, test } from "bun:test"
import { pushNotificationController } from "./pushNotifications"

test("pushNotifications", () => {
  const { registerDevice, removeDevice, getDoorbellRingSubscribers } =
    pushNotificationController(":memory:")
  registerDevice("user", "token", ["doorbellRing"])
  expect(getDoorbellRingSubscribers()).toEqual([
    {
      deviceToken: "token",
      username: "user",
    },
  ])
  removeDevice("token")
  expect(getDoorbellRingSubscribers()).toEqual([])
})

test("pushNotifications - register twice", () => {
  const { registerDevice } = pushNotificationController(":memory:")
  registerDevice("user", "token", ["doorbellRing"])
  registerDevice("user", "token", ["doorbellRing"])
  expect(true).toBeTrue()
})

test("pushNotifications - other user arrives", () => {
  const { registerDevice, getWhenOtherUserArrivesSubscribers } =
    pushNotificationController(":memory:")
  registerDevice("alice", "token1", ["whenOtherUserArrives"])
  registerDevice("bob", "token2", ["whenOtherUserArrives"])
  expect(getWhenOtherUserArrivesSubscribers("bob")).toEqual([
    {
      deviceToken: "token1",
      username: "alice",
    },
  ])
})

test("pushNotifications - already prepared", () => {
  const { prepare } = pushNotificationController(":memory:")
  prepare()
  expect(true).toBeTrue()
})
