import { z } from "zod"
import { findUser } from "./lib/user"
import { getAuthHeader } from "./lib/auth"
import { Action } from "./lib/action"

const port = 4278

const sendRequest = async (
  method: "GET" | "POST",
  action: Action
): Promise<unknown> => {
  const max = findUser("max")
  if (max === null) throw new Error("user not found")

  const url = `http://localhost:${port}${action}`
  const response = await fetch(url, {
    method,
    headers: {
      authorization: getAuthHeader(
        max.username,
        max.secret,
        action,
        Math.floor(Date.now() / 1000)
      ),
    },
  })
  const text = await response.text()
  try {
    return await JSON.parse(text)
  } catch (error) {
    console.log(text)
    console.log(error)
    return undefined
  }
}

const command = z.enum(["doorbell", "arrived"])
type Command = z.infer<typeof command>

const main = async (command: Command) => {
  switch (command) {
    case "doorbell":
      await sendRequest("POST", "/doorbell")
      break
    case "arrived":
      await sendRequest("POST", "/arrived")
      break
  }
}

main(command.parse(process.argv[2]))
