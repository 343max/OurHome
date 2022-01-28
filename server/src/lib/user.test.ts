import { findUser, User } from "./user.ts"
import { assertEquals } from "https://deno.land/std@0.123.0/testing/asserts.ts"

Deno.test("findUser", () => {
  const fakeUsers: User[] = [
    {
      name: "ringo",
      secret: "aaa",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      name: "george",
      secret: "bbbb",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      name: "john",
      secret: "dead",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      name: "paul",
      secret: "deaf",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
  ]

  const user = findUser("john", fakeUsers)!
  console.log(user)
  assertEquals(user.name, "john")

  assertEquals(findUser("nobody", fakeUsers), null)
})
