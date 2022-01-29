import { allUsers } from "../secrets.ts"

export type Permission = "full" | "local" | "none"

export type Permissions = Record<"buzzer" | "frontdoor" | "unlatch", Permission>

export type User = {
  name: string
  secret: string
  permissions: Permissions
}

export const findUser = (name: string, users: User[] = allUsers): User | null =>
  users.find((user) => user.name === name) ?? null
