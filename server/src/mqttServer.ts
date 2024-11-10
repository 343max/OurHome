import { createServer } from "node:net";
import Aedes from "aedes";
import type { MqttServerConfiguration } from "./lib/config";

export const setupMqttServer = (config: MqttServerConfiguration) => {
    const aedes = new Aedes();

    aedes.on("publish", (event) => {
        if (event.topic === config.homeKeyAuthTopic) {
            try {
                const payload = JSON.parse(event.payload.toString());
                console.log("auth", payload);
            } catch (e) {
                console.log("could not parse auth payload");
            }
        }
    });

    const server = createServer(aedes.handle);

    return server;
};
