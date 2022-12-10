import { createHash } from "../deps.ts"
import { getRuntimeConfig } from "./config.ts"
import { Action } from "./action.ts"
import { findUser, Permission, Permissions, User } from "./user.ts"

export const getToken = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string =>
  createHash("sha256")
    .update([user, secret, action, `${unixTimeSecs}`].join(":"))
    .digest("base64")
    .toString()

export const getAuthHeader = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string => {
  const token = getToken(user, secret, action, unixTimeSecs)
  return [user, token, `${unixTimeSecs}`].join(":")
}

type UserLocation = "local" | "remote"

export const accessAllowed = (
  userAccess: Permission,
  userLocation: UserLocation
): boolean => {
  const allowedLevel = ["none", "local", "full"].indexOf(userAccess)
  const requestedLevel = ["", "local", "remote"].indexOf(userLocation)
  return allowedLevel >= requestedLevel
}

export const splitAuthHeader = (
  authHeader: string | null
): { username: string; token: string; timestamp: number } | null => {
  const result = authHeader === null ? [] : authHeader.split(":")
  if (result.length != 3) {
    return null
  }
  const [username, token, timestamp] = result
  return { username, token, timestamp: parseInt(timestamp) }
}

export const verifyTimestamps = (
  timestampA: number,
  timestampB: number
): boolean => Math.abs(timestampA - timestampB) < 5 * 60

export const getPermissionsKey = (action: Action): null | keyof Permissions => {
  const mapping: Record<Action, null | keyof Permissions> = {
    user: null,
    state: null,
    buzzer: "buzzer",
    lock: "frontdoor",
    unlock: "frontdoor",
    unlatch: "unlatch",
    arrived: "arm/buzzer",
    doorbell: null,
    "arm/unlatch": "arm/unlatch",
    "arm/buzzer": "arm/buzzer",
  }
  return mapping[action]
}

export const verifyAuth = (
  header: string | null,
  action: Action,
  userLocation: UserLocation,
  now: number = new Date().getTime() / 1000,
  users?: User[]
): boolean => {
  const skipAuth = getRuntimeConfig().ignoreAuthentication

  if (header === null) {
    return false
  }

  const headerParts = splitAuthHeader(header)
  if (headerParts === null) {
    return false
  }

  const { username, token, timestamp } = headerParts

  if (!skipAuth && !verifyTimestamps(timestamp, now)) {
    return false
  }

  const user = findUser(username, users)
  if (user === null) {
    return false
  }

  if (
    !skipAuth &&
    getToken(user.username, user.secret, action, timestamp) !== token
  ) {
    return false
  }

  const permissionsKey = getPermissionsKey(action)
  if (permissionsKey !== null) {
    if (!accessAllowed(user.permissions[permissionsKey], userLocation)) {
      return false
    }
  }

  console.log(`🧑 Authorized user: ${user.username}`)

  return true
}
