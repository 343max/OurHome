import { z } from "zod";
import type { Buzzer } from "./buzzer";
import type { Nuki } from "./nuki";

const BuzzerSchema = z.discriminatedUnion("type", [
    z.object({
        type: z.literal("dummy"),
    }),
    z.object({
        type: z.literal("serial"),
        path: z.string(),
    }),
]);

const NukiSchema = z.discriminatedUnion("type", [
    z.object({
        type: z.literal("dummy"),
    }),
    z.object({
        type: z.literal("live"),
        host: z.string(),
        port: z.number(),
        token: z.string(),
        deviceId: z.number(),
    }),
]);

const configurationSchema = z.object({
    buzzer: BuzzerSchema,
    nuki: NukiSchema,
    buzzerArmTimeout: z.number(),
    unlatchArmTimeout: z.number(),
    arrivalTimeout: z.number(),
    applePushNotifications: z.object({
        deviceTokenDBPath: z.string(),
        teamId: z.string(),
        signingKeyId: z.string(),
        signingKey: z.string(),
        topic: z.string(),
        production: z.boolean(),
    }),
    disableAuth: z.boolean().optional(),
    httpPort: z.number(),
});

export type Configuration = Omit<
    z.infer<typeof configurationSchema>,
    "buzzer" | "nuki"
> & { buzzer: Buzzer; nuki: Nuki };
