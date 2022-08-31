import { allUsers } from "../secrets.ts"

export type Permission = "full" | "local" | "none"

export type Permissions = Record<
  "buzzer" | "frontdoor" | "unlatch" | "arrived",
  Permission
>

export type User = {
  username: string
  displayName: string
  secret: string
  permissions: Permissions
}

export const findUser = (
  username: string,
  users: User[] = allUsers
): User | null => users.find((user) => user.username === username) ?? null
