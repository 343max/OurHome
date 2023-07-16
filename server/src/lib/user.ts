import { allUsers } from "../secrets.ts"

const permissionTypes = ["full", "local", "none"] as const
export type Permission = (typeof permissionTypes)[number]

export type Permissions = Record<
  "buzzer" | "frontdoor" | "unlatch" | "arm/buzzer" | "arm/unlatch",
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

export const dumpInviteLinks = () => {
  const inviteLinks = allUsers.map(
    ({ username, secret }) =>
      `de.343max.ourhome://login?user=${username}&key=${secret}`
  )

  console.log(inviteLinks.join("\n"))
}
