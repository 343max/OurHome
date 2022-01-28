import { Action } from "./action.ts"
import { createHash } from "https://deno.land/std@0.77.0/hash/mod.ts"
import { Access } from "./user.ts"

export const getToken = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string =>
  createHash("sha256")
    .update([user, secret, action, `${unixTimeSecs}`].join(":"))
    .toString("base64")

export const getAuthHeader = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string => {
  const token = getToken(user, secret, action, unixTimeSecs)
  return [user, token, `${unixTimeSecs}`].join(":")
}

type ActionScope = "local" | "remote"

export const accessAllowed = (
  userAccess: Access,
  requestedAccess: ActionScope
): boolean => {
  const allowedLevel = ["none", "local", "full"].indexOf(userAccess)
  const requestedLevel = ["", "local", "remote"].indexOf(requestedAccess)
  return allowedLevel >= requestedLevel
}

export const splitAuthHeader = (
  authHeader: string
): { username: string; token: string; timestamp: number } | null => {
  const result = authHeader.split(":")
  if (result.length != 3) {
    return null
  }
  const [username, token, timestamp] = result
  return { username, token, timestamp: parseInt(timestamp) }
}

export const verifyAuth = (
  header: string,
  action: Action,
  local: boolean,
  date: number = new Date().getTime() / 1000
): boolean => {
  // check date
  // check user auth
  // check permission level
  return false
}
