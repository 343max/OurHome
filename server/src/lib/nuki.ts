import { z } from "zod";

export const nukiSmartLockState = z.number().min(0).max(255);

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

export const nukiSmartLockConfig = z.object({
    state: nukiSmartLockState,
    batteryCritical: z.boolean(),
    batteryCharging: z.boolean(),
    batteryChargeState: z.number(),
    success: z.boolean(),
});

export type NukiSmartLockConfig = z.infer<typeof nukiSmartLockConfig>;

export const nukiResponse = z.object({
    success: z.boolean(),
    batteryCritical: z.boolean(),
    batteryCharging: z.boolean(),
    batteryChargeState: z.number(),
});

export type NukiResponse = z.infer<typeof nukiResponse> | { success: false };

export type Nuki = {
    lock: () => Promise<NukiResponse>;
    unlock: () => Promise<NukiResponse>;
    unlatch: () => Promise<NukiResponse>;
    getState: () => Promise<NukiSmartLockConfig | null>;
};
