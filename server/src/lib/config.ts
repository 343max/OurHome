import { Buzzer } from "./buzzer.ts"

export type NukiConfiguration = {
  host: string
  port: number
  token: string
  deviceId: number
}

export type Configuration = {
  buzzer: Buzzer
  nuki: NukiConfiguration
}

type EnvOverwrites = { ignoreAuthentication: boolean }

export const getRuntimeConfig = (): EnvOverwrites => ({
  ignoreAuthentication: Deno.env.get("DISABLE_AUTH") === "1",
})
