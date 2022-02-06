import { NukiConfiguration } from "./config.ts"

export const getNukiUrl = (
  action: string,
  { host, port, token, deviceId }: NukiConfiguration,
  params: { [key: string]: string | number } = {}
): string => {
  const allParams = Object.entries({ token, nukiId: deviceId, ...params })
    .map(([key, value]) => `${key}=${value}`)
    .join("&")
  return `http://${host}:${port}/${action}?${allParams}`
}

// deno-lint-ignore no-explicit-any
const parseJson = async (response: Response): Promise<any> => {
  try {
    return await response.json()
  } catch (error) {
    throw Error([error, `tried to parse: ${await response.text()}`].join("\n"))
  }
}

export const nukiLock = async (config: NukiConfiguration) =>
  await parseJson(await fetch(getNukiUrl("lock", config)))

export const nukiUnlock = async (config: NukiConfiguration) =>
  await parseJson(await fetch(getNukiUrl("unlock", config)))

export const nukiUnlatch = async (config: NukiConfiguration) =>
  await parseJson(await fetch(getNukiUrl("lockAction", config, { action: 3 })))

export enum NukiSmartLockState {
  Uncalibrated = 0,
  Locked = 1,
  Unlocking = 2,
  Unlocked = 3,
  Locking = 4,
  Unlatched = 5,
  UnlockedLockNGo = 6,
  Unlatching = 7,
  MotorBlocked = 254,
  Undefined = 255,
}

type NukiSmartLockConfig = {
  mode: number
  state: NukiSmartLockState
  batteryCritical: false
  batteryCharging: false
  batteryChargeState: 85
  success: true
}

export const getNukiLockConfig = async (
  config: NukiConfiguration
): Promise<NukiSmartLockConfig> =>
  await (await fetch(getNukiUrl("lockState", config))).json()
