import { Nuki } from "./nuki.ts"
import { NukiSmartLockConfig, NukiSmartLockState } from "./nuki.ts"
import { sleep } from "../deps.ts"

export const dummyNuki = (): Nuki => {
  const state: NukiSmartLockConfig = {
    mode: 0,
    state: NukiSmartLockState.Locked,
    batteryCritical: false,
    batteryCharging: false,
    batteryChargeState: 76,
    success: true,
  }

  return {
    lock: async () => {
      state.state = NukiSmartLockState.Locking
      console.log("🔒 nuki lock")
      await sleep(0.5)
      state.state = NukiSmartLockState.Locked
      return { success: true }
    },
    unlock: async () => {
      state.state = NukiSmartLockState.Unlocking
      console.log("🔓 nuki unlocked")
      await sleep(0.5)
      state.state = NukiSmartLockState.Unlocked
      return { success: true }
    },
    unlatch: async () => {
      state.state = NukiSmartLockState.Unlatching
      console.log("🔓 nuki unlatched")
      await sleep(1)
      state.state = NukiSmartLockState.Unlocked
      return { success: true }
    },
    getState: async () => {
      console.log("returned nuki state")
      await sleep(0.5)
      return state
    },
  }
}
