import { apiServer } from "./lib/apiServer";
import { buildInfo } from "./lib/buildinfo";
import { loadConfiguration } from "./lib/config";
import { pushNotificationSender } from "./lib/pushNotificationsSender";
import { dumpInviteLinks } from "./lib/user";
import { setupMqttServer } from "./mqttServer";

const configurationPath = process.argv[2];

if (configurationPath === undefined) {
    throw new Error("Configuration path not provided");
}

const configuration = loadConfiguration(configurationPath);

const sendPush = pushNotificationSender(configuration.applePushNotifications);

if (configuration.disableAuth) {
    console.log(
        "⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️",
    );
}

const port = configuration.httpPort;

console.log(`🌳 server running at http://localhost:${port}/ 🌳`);
console.log(`👷 build date: ${buildInfo.date}`);

dumpInviteLinks(configuration.users);

const main = async () => {
    (await apiServer(configuration, sendPush)).listen(port);

    const mqttConfig = configuration.mqttServer;
    if (mqttConfig?.enabled) {
        const mqttServer = await setupMqttServer(
            mqttConfig,
            configuration.nuki.unlatch,
        );
        mqttServer.listen(mqttConfig.port, mqttConfig.host, () => {
            console.log(`🌳 mqtt server running at ${mqttConfig.port} 🌳`);
        });
    }
};

main();
