import { Action } from "./action.ts"
import { createHash } from "https://deno.land/std@0.77.0/hash/mod.ts"
import { Access } from "./user.ts"

const getToken = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string =>
  createHash("sha256")
    .update([user, secret, action, `${unixTimeSecs}`].join("/"))
    .toString("base64")

export const getAuthHeader = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string => {
  const token = getToken(user, secret, action, unixTimeSecs)
  return [user, token, `${unixTimeSecs}`].join("/")
}

export const accessAllowed = (
  userAccess: Access,
  wantsPerform: "local" | "remote"
): boolean => false

export const verifyAuth = (
  header: string,
  action: Action,
  local: boolean,
  date: number = new Date().getTime() / 1000
): boolean => false
