import { createServer } from "node:net";
import Aedes from "aedes";
import type { MqttServerConfiguration } from "./lib/config";

export const setupMqttServer = (
    config: MqttServerConfiguration,
    authAction: () => void,
) => {
    if (
        config.authentication === true &&
        (config.username === undefined || config.password === undefined)
    ) {
        throw new Error(
            "MQTT authentication enabled but username or password not set. Please set username and password in the config or explicitly set authentication to false.",
        );
    }

    const aedes = new Aedes({
        authenticate: (_client, username, passwordBuffer, done) => {
            const password = passwordBuffer?.toString() ?? "";
            const valid =
                username === config.username && password === config.password;

            done(
                valid
                    ? null
                    : {
                          name: "Authentication Error",
                          message: "Authentication Failed",
                          returnCode: 1,
                      },
                valid,
            );
        },
    });

    aedes.on("publish", (event) => {
        if (event.topic === config.homeKeyAuthTopic) {
            try {
                const payload = JSON.parse(event.payload.toString());

                if (payload.homekey === true) {
                    authAction();
                } else {
                    console.log("ignoring nfc card", payload);
                }
            } catch (e) {
                console.log("could not parse auth payload");
            }
        }
    });

    const server = createServer(aedes.handle);

    return server;
};
