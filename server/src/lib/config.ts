import { Buzzer } from "./buzzer.ts"
import { Nuki } from "./nuki.ts"

export type Configuration = {
  buzzer: Buzzer
  nuki: Nuki
  buzzerArmTimeout: number
  unlatchArmTimeout: number
  arrivalTimeout: number
}

type EnvOverwrites = { ignoreAuthentication: boolean }

export const getRuntimeConfig = (): EnvOverwrites => ({
  ignoreAuthentication: Deno.env.get("DISABLE_AUTH") === "1",
})
