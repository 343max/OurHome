import fs from "node:fs";
import { z } from "zod";
import { type Buzzer, dummyBuzzer, serialBuzzer } from "./buzzer";
import { dummyNuki } from "./dummyNuki";
import { liveNuki } from "./liveNuki";
import type { Nuki } from "./nuki";
import { UserSchema } from "./user";

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

const mqttServerSchema = z.object({
    enabled: z.boolean().default(false),
    host: z.string().optional(),
    port: z.number().default(1883),
    authentication: z.boolean().default(true),
    username: z.string().optional(),
    password: z.string().optional(),
    homeKeyAuthTopic: z.string().default("ESP32_285A44/homekey/auth"),
});

export type MqttServerConfiguration = z.infer<typeof mqttServerSchema>;

export const configurationJsonSchema = z.object({
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
    users: z.array(UserSchema),
    mqttServer: mqttServerSchema.optional(),
    $schema: z.string().optional(), // to allow the schema to be set in the config.json
});

type ConfigurationJson = z.infer<typeof configurationJsonSchema>;

export type Configuration = Omit<
    ConfigurationJson,
    "buzzer" | "nuki" | "$schema"
> & {
    buzzer: Buzzer;
    nuki: Nuki;
};

export const buildConfiguration = (
    jsonConfig: ConfigurationJson,
): Configuration => {
    const { buzzer, nuki, ...config } = jsonConfig;
    return {
        ...config,
        buzzer:
            buzzer.type === "dummy" ? dummyBuzzer() : serialBuzzer(buzzer.path),
        nuki: nuki.type === "dummy" ? dummyNuki() : liveNuki(nuki),
    };
};

export const loadConfiguration = (path: string): Configuration => {
    const jsonConfig = configurationJsonSchema.parse(
        JSON.parse(fs.readFileSync(path, "utf8")),
    );
    return buildConfiguration(jsonConfig);
};
