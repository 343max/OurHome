import {
  NukiDeviceState,
  NukiSmartLockState,
  SmartLockState,
} from "./nukiDeviceState.ts"
import { NukiConfiguration } from "./config.ts"

export const getNukiUrl = (
  action: string,
  { host, port, token }: Omit<NukiConfiguration, "deviceId">
): string => `http://${host}:${port}/${action}?token=${token}`

export const getNukiStatus = async (
  config: Omit<NukiConfiguration, "deviceId">
): Promise<NukiDeviceState[]> =>
  await (await fetch(getNukiUrl("list", config))).json()

export const getNukiDeviceStatus = async ({
  deviceId,
  ...config
}: NukiConfiguration): Promise<{
  state: SmartLockState
  battery: { critical: boolean; charging: boolean; chargeState: number }
  timestamp: string
} | null> => {
  const device = (await getNukiStatus(config)).find(
    ({ nukiId, deviceType }) => nukiId === deviceId && deviceType === 4
  ) as NukiSmartLockState | undefined

  if (device === undefined) {
    return null
  } else {
    return {
      state: device.lastKnownState.state,
      battery: {
        critical: device.lastKnownState.batteryCritical,
        charging: device.lastKnownState.batteryCharging,
        chargeState: device.lastKnownState.batteryChargeState,
      },
      timestamp: device.lastKnownState.timestamp,
    }
  }
}
