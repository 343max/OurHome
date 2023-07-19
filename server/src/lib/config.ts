import { Buzzer } from "./buzzer.ts"
import { env } from "./env.ts"
import { Nuki } from "./nuki.ts"

export type NtfyshConfig = {
  username: string
  password: string
  ntfyUrl: string
}

export type Configuration = {
  buzzer: Buzzer
  nuki: Nuki
  buzzerArmTimeout: number
  unlatchArmTimeout: number
  arrivalTimeout: number
  doorbellNtfy: NtfyshConfig | null
}

type EnvOverwrites = { ignoreAuthentication: boolean }

export const getRuntimeConfig = (): EnvOverwrites => ({
  ignoreAuthentication: env().DISABLE_AUTH === "1",
})
