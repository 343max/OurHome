import { getRuntimeConfig } from "./config"
import { Action } from "./action"
import { findUser, Permission, Permissions, User } from "./user"
import { createHash } from "crypto"

export const getToken = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string =>
  createHash("sha256")
    .update(
      [user, secret, action.replace(/^\//, ""), `${unixTimeSecs}`].join(":")
    )
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
  authHeader: string | undefined
): { username: string; token: string; timestamp: number } | null => {
  const result = authHeader === undefined ? [] : authHeader.split(":")

  const [username, token, timestamp] = result
  if (username === undefined || token === undefined || timestamp === undefined)
    return null

  return { username, token, timestamp: parseInt(timestamp) }
}

export const verifyTimestamps = (
  timestampA: number,
  timestampB: number
): boolean => Math.abs(timestampA - timestampB) < 5 * 60

const getPermissions = (
  action: Action,
  permissions: Permissions
): null | Permission => {
  const mapping: Record<Action, null | Permission> = {
    "/user": null,
    "/state": null,
    "/buzzer": permissions["buzzer"],
    "/lock": permissions["frontdoor"],
    "/unlock": permissions["frontdoor"],
    "/unlatch": permissions["unlatch"],
    "/doorbell": null,
    "/arrived": permissions["arm/buzzer"],
    "/arm/unlatch": permissions["arm/unlatch"],
    "/arm/buzzer": permissions["arm/buzzer"],
    "/pushnotifications": "full",
  }
  return mapping[action]
}

export const verifyAuth = (
  header: string | undefined,
  action: Action,
  userLocation: UserLocation,
  now: number = new Date().getTime() / 1000,
  users?: User[]
): boolean => {
  const skipAuth = getRuntimeConfig().ignoreAuthentication

  if (header === undefined) {
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

  const permission = getPermissions(action, user.permissions)

  if (permission !== null) {
    if (!accessAllowed(permission, userLocation)) {
      return false
    }
  }

  console.log(`🧑 Authorized user: ${user.username}`)

  return true
}
