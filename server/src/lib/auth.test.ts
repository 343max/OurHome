import { accessAllowed, getAuthHeader, getToken, splitAuthHeader, verifyTimestamps } from "./auth"

test("authHeader", () => {
  const authHeader = getAuthHeader("max", "abcdef", "/lock", 4223)
  expect(authHeader).toBe("max:n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=:4223")
})

test("make sure different params create different headers", () => {
  const authHeader = getToken("max", "abcdef", "/lock", 4223)
  expect(authHeader).not.toBe(getToken("max", "abcdef", "/lock", 123))
  expect(authHeader).not.toBe(getToken("not max", "abcdef", "/lock", 4223))
  expect(authHeader).not.toBe(getToken("max", "other secret", "/lock", 4223))
  expect(authHeader).not.toBe(getToken("max", "abcdef", "/unlatch", 4223))
})

test("check actions", () => {
  expect(accessAllowed("full")).toBeTruthy()
  expect(accessAllowed("local")).toBeTruthy()
  expect(accessAllowed("none")).toBeFalsy()
})

test("split auth header", () => {
  const { username, token, timestamp } = splitAuthHeader("max:n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=:4223")!

  expect(username).toBe("max")
  expect(token).toBe("n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=")
  expect(timestamp).toBe(4223)

  expect(splitAuthHeader("")).toBeNull()
})

test("verify date", () => {
  expect(verifyTimestamps(500, 510)).toBeTruthy()
  expect(verifyTimestamps(5000, 5500)).toBeFalsy()
  expect(verifyTimestamps(5000, 4500)).toBeFalsy()
})
