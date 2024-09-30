import { buildConfiguration } from "./config";

test("buildConfig", () => {
    const config = buildConfiguration({
        buzzer: { type: "dummy" },
        nuki: { type: "dummy" },
        arrivalTimeout: 15,
        buzzerArmTimeout: 10,
        unlatchArmTimeout: 3,
        applePushNotifications: {
            deviceTokenDBPath: "./db/device_tokens.sqlite",
            teamId: "ATMW4AU45H",
            signingKeyId: "C988QWV66B",
            signingKey: "./keys/AuthKey_C988QWV66B.p8",
            topic: "de.343max.ourhome.Our-Home",
            production: true,
        },
        httpPort: 4278,
        users: [
            {
                username: "max",
                displayName: "Max",
                secret: "22748b307993df25dd90f9cdbe981bd82d2c40865be4c344dc9290c087f88e1b",
                permissions: {
                    buzzer: "full",
                    frontdoor: "local",
                    unlatch: "local",
                    "arm/buzzer": "full",
                    "arm/unlatch": "full",
                },
            },
        ],
    });

    expect(config.nuki.lock).toBeInstanceOf(Function);
    expect(config.buzzer().pressBuzzer).toBeInstanceOf(Function);
});
