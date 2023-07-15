import { Nuki } from "./nuki.ts"
import { NukiSmartLockConfig, NukiSmartLockState } from "./nuki.ts"

export const dummyNuki = (): Nuki => {
  const state: NukiSmartLockConfig = {
    state: NukiSmartLockState.Locked,
    batteryCritical: false,
    batteryCharging: false,
    batteryChargeState: 42,
    success: true,
  }

  return {
    lock: async () => {
      state.state = NukiSmartLockState.Locking
      console.log("🔒 nuki lock")
      await Bun.sleep(500)
      state.state = NukiSmartLockState.Locked
      return { success: true }
    },
    unlock: async () => {
      state.state = NukiSmartLockState.Unlocking
      console.log("🔓 nuki unlocked")
      await Bun.sleep(500)
      state.state = NukiSmartLockState.Unlocked
      return { success: true }
    },
    unlatch: async () => {
      state.state = NukiSmartLockState.Unlatching
      console.log("🔓 nuki unlatched")
      await Bun.sleep(1000)
      state.state = NukiSmartLockState.Unlocked
      return { success: true }
    },
    getState: async () => {
      console.log("returned nuki state")
      await Bun.sleep(500)
      return state
    },
  }
}
