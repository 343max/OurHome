import { NukiConfiguration } from "./config.ts"

export const getNukiRequest = (
  action: string,
  { host, port, token, deviceId }: NukiConfiguration,
  params: { [key: string]: string | number } = {}
): Request => {
  const allParams = Object.entries({ token, nukiId: deviceId, ...params })
    .map(([key, value]) => `${key}=${value}`)
    .join("&")
  return new Request(`http://${host}:${port}/${action}?${allParams}`, {
    headers: { "Content-Type": "application/json", Accept: "application/json" },
  })
}

// deno-lint-ignore no-explicit-any
const parseJson = async (response: Response): Promise<any> => {
  const text = await response.text()
  try {
    return JSON.parse(text)
  } catch (error) {
    throw Error(
      [error, `tried to parse: ${text}`, `status: ${response.status}`].join(
        "\n"
      )
    )
  }
}

export const nukiLock = async (config: NukiConfiguration) =>
  await parseJson(await fetch(getNukiRequest("lock", config)))

export const nukiUnlock = async (config: NukiConfiguration) =>
  await parseJson(await fetch(getNukiRequest("unlock", config)))

export const nukiUnlatch = async (config: NukiConfiguration) =>
  await parseJson(
    await fetch(getNukiRequest("lockAction", config, { action: 3 }))
  )

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
  await parseJson(await fetch(getNukiRequest("lockState", config)))
