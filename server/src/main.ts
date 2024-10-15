import express from "express";
import {
    APNTokenDBController,
    pushNotificationRegistration,
} from "./lib/APNTokenDb";
import { splitAuthHeader } from "./lib/auth";
import { authorized } from "./lib/authorized";
import { buildInfo } from "./lib/buildinfo";
import { loadConfiguration } from "./lib/config";
import { setupDoorLockController } from "./lib/doorLockController";
import { defaultPlannedActions } from "./lib/plannedActions";
import { pushNotificationSender } from "./lib/pushNotificationsSender";
import { dumpInviteLinks, findUser } from "./lib/user";

const configurationPath = process.argv[2];

if (configurationPath === undefined) {
    throw new Error("Configuration path not provided");
}

const configuration = loadConfiguration(configurationPath);

const app = express();

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
    const plannedActions = defaultPlannedActions;

    const {
        registerDevice,
        removeDevice,
        getDoorbellRingSubscribers,
        getWhenOtherUserArrivesSubscribers,
        getUserTokens,
    } = await APNTokenDBController(
        configuration.applePushNotifications.deviceTokenDBPath,
    );

    const doorLockController = setupDoorLockController(
        plannedActions,
        { ...configuration, buzzer: configuration.buzzer() },
        {
            handleAnonymousDoorbellPress: async () =>
                await sendPush(
                    {
                        title: "Our Home",
                        body: "🔔 Ding! Dong!",
                        category: "buzzer",
                    },
                    undefined,
                    await getDoorbellRingSubscribers(),
                ),
            handleUnlatchingDoorBecauseOfRing: async (armedBy) =>
                await sendPush(
                    {
                        title: "Our Home",
                        body: "Buzzer wird gedrückt.",
                        category: "buzzer",
                    },
                    undefined,
                    await getUserTokens(armedBy),
                ),
            handleUserArrived: async (username) => {
                const { displayName } = findUser(
                    username,
                    configuration.users,
                ) ?? {
                    displayName: undefined,
                };

                const whenOtherUserArrivesSubscribers =
                    await getWhenOtherUserArrivesSubscribers(username);

                sendPush(
                    {
                        title: "Our Home",
                        body: `👋 ${displayName} ist da!`,
                        category: "buzzer",
                    },
                    undefined,
                    whenOtherUserArrivesSubscribers,
                );

                plannedActions.armForPlannedAction({
                    type: "buzzer",
                    timeout: configuration.arrivalTimeout,
                    armedBy: username,
                });
            },
        },
    );

    app.use(express.json())
        .all("*", (req, _res, next) => {
            if (!["HEAD /", "GET /"].includes(`${req.method} ${req.url}`)) {
                console.log(`🌎 ${req.ip} ${req.method} ${req.url}`);
            }
            next();
        })
        .post(
            ...authorized("/buzzer", configuration, async (_req, res) => {
                await doorLockController.pressBuzzer();
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/lock", configuration, async (_req, res) =>
                res.send(await doorLockController.lockDoor()),
            ),
        )
        .post(
            ...authorized("/unlock", configuration, async (_req, res) =>
                res.send(await doorLockController.unlockDoor()),
            ),
        )
        .post(
            ...authorized("/unlatch", configuration, async (_req, res) =>
                res.send(await doorLockController.unlatchDoor()),
            ),
        )
        .get(
            ...authorized("/user", configuration, (req, res) => {
                const authHeader = splitAuthHeader(req.headers.authorization);
                if (authHeader === null) {
                    res.send({ sucess: false });
                    return;
                }
                // biome-ignore lint/style/noNonNullAssertion: code can't be reached when user doesn't exists
                const { secret: _secret, ...userInfo } = findUser(
                    authHeader.username,
                    configuration.users,
                )!;
                res.send({ success: true, userInfo });
            }),
        )
        .get(
            ...authorized("/state", configuration, async (_req, res) =>
                res.send({
                    success: true,
                    doorlock: await doorLockController.getNukiState(),
                    doorbellAction:
                        defaultPlannedActions.getCurrentPlannedAction(),
                }),
            ),
        )
        .post(
            ...authorized("/arrived", configuration, async (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;

                await doorLockController.userArrived(username);

                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/arm/buzzer", configuration, (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                doorLockController.armBuzzer(username);
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/arm/unlatch", configuration, (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                doorLockController.armUnlatch(username);
                res.send({ success: true });
            }),
        )
        .get(
            ...authorized(
                "/pushnotifications/:deviceToken",
                configuration,
                (req, res) => {
                    res.send({ deviceToken: req.params.deviceToken });
                },
            ),
        )
        .put(
            ...authorized(
                "/pushnotifications/:deviceToken",
                configuration,
                async (req) => {
                    // biome-ignore lint/style/noNonNullAssertion: <explanation>
                    const username = splitAuthHeader(
                        req.headers.authorization,
                    )!.username;
                    const { types } = pushNotificationRegistration.parse(
                        req.body,
                    );
                    registerDevice(username, req.params.deviceToken, types);
                    return { success: true };
                },
            ),
        )
        .delete(
            ...authorized(
                "/pushnotifications/:deviceToken",
                configuration,
                async (req) => {
                    removeDevice(req.params.deviceToken);
                    return { success: true };
                },
            ),
        )
        .get("/", (_req, res) =>
            res.send({ success: true, message: "please leave me alone" }),
        )
        .head("/", (_req, res) =>
            res.send({ success: true, message: "please leave me alone" }),
        )
        .get("/.well-known/apple-app-site-association", (_req, res) =>
            res.send({
                applinks: {
                    details: [
                        {
                            appID: "ATMW4AU45H.de.343max.ourhome.Our-Home",
                            paths: ["/*"],
                        },
                        {
                            appID: "ATMW4AU45H.de.343max.OurHome.OHWatch.watchkitapp",
                            paths: ["/*"],
                        },
                    ],
                },
            }),
        )
        .listen(port);
};

main();
