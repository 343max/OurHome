import { NtfyshConfig } from "./config"

export const sendNotification = async (
  message: string,
  { username, password, ntfyUrl }: NtfyshConfig
) => {
  return await fetch(ntfyUrl, {
    method: "POST",
    body: message,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${Buffer.from(`${username}:${password}`).toString(
        "base64"
      )}`,
    },
  })
}
