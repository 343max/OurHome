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

export type NukiSmartLockConfig = {
  state: NukiSmartLockState
  batteryCritical: boolean
  batteryCharging: boolean
  batteryChargeState: number
  success: boolean
}

// deno-lint-ignore no-explicit-any
export type Json = any

export type Nuki = {
  lock: () => Promise<Json>
  unlock: () => Promise<Json>
  unlatch: () => Promise<Json>
  getState: () => Promise<NukiSmartLockConfig>
}
