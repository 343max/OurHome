export enum SmartLockState {
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

type NukiCommonState = {
  nukiId: number
  name: string
  firmwareVersion: string
  lastKnownState: { timestamp: string }
}

type NukiGenericDeviceState = NukiCommonState & { deviceType: number }
export type NukiSmartLockState = NukiCommonState & {
  deviceType: 4
  lastKnownState: {
    mode: number
    state: SmartLockState
    batteryCritical: boolean
    batteryCharging: boolean
    batteryChargeState: number
  }
}

export type NukiDeviceState = NukiGenericDeviceState | NukiSmartLockState
