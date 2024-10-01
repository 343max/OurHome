import type { Nuki } from "./nuki";
import { type NukiSmartLockConfig, NukiSmartLockState } from "./nuki";
import { sleep } from "./sleep";

export const dummyNuki = (): Nuki => {
    const state: NukiSmartLockConfig = {
        state: NukiSmartLockState.Locked,
        batteryCritical: false,
        batteryCharging: false,
        batteryChargeState: 42,
        success: true,
    };

    const successResponse = {
        batteryCritical: false,
        batteryCharging: false,
        batteryChargeState: 42,
        success: true,
    };

    return {
        lock: async () => {
            state.state = NukiSmartLockState.Locking;
            console.log("🔒 nuki lock");
            await sleep(500);
            state.state = NukiSmartLockState.Locked;
            return successResponse;
        },
        unlock: async () => {
            state.state = NukiSmartLockState.Unlocking;
            console.log("🔓 nuki unlocked");
            await sleep(500);
            state.state = NukiSmartLockState.Unlocked;
            return successResponse;
        },
        unlatch: async () => {
            state.state = NukiSmartLockState.Unlatching;
            console.log("🔓 nuki unlatched");
            await sleep(1000);
            state.state = NukiSmartLockState.Unlocked;
            return successResponse;
        },
        getState: async () => {
            console.log("returned nuki state");
            await sleep(500);
            return state;
        },
    };
};
