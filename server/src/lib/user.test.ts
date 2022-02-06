import { findUser, User } from "./user.ts"
import { assertEquals } from "https://deno.land/std@0.123.0/testing/asserts.ts"

Deno.test("findUser", () => {
  const fakeUsers: User[] = [
    {
      username: "ringo",
      displayName: "Ringo Start",
      secret: "aaa",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      username: "george",
      displayName: "George Harrison",
      secret: "bbbb",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      username: "john",
      displayName: "John Lennon",
      secret: "dead",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
    {
      username: "paul",
      displayName: "Paul McCartney",
      secret: "deaf",
      permissions: { frontdoor: "full", buzzer: "full", unlatch: "full" },
    },
  ]

  const user = findUser("john", fakeUsers)!
  console.log(user)
  assertEquals(user.username, "john")

  assertEquals(findUser("nobody", fakeUsers), null)
})
