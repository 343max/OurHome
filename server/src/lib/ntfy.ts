import { NtfyshConfig } from "./config.ts"
import { base64 } from "../deps.ts"

export const sendNotification = async (
  message: string,
  { username, password, ntfyUrl }: NtfyshConfig
) => {
  return await fetch(ntfyUrl, {
    method: "POST",
    body: message,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${base64.encode(`${username}:${password}`)}`,
    },
  })
}
