import express from "express";
import {
    armForDoorBellAction,
    getCurrentDoorbellAction,
} from "./lib/arrivedRecently";
import { splitAuthHeader } from "./lib/auth";
import { authorized } from "./lib/authorized";
import { buildInfo } from "./lib/buildinfo";
import { createHandleDoorbellPress } from "./lib/handleDoorbellPress";
import {
    pushNotificationController,
    pushNotificationRegistration,
} from "./lib/pushNotifications";
import { pushNotificationSender } from "./lib/pushNotificationsSender";
import { sleep } from "./lib/sleep";
import { dumpInviteLinks, findUser } from "./lib/user";
import { configuration } from "./secrets";

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

dumpInviteLinks();

const main = async () => {
    const buzzer = configuration.buzzer();
    const {
        registerDevice,
        removeDevice,
        getDoorbellRingSubscribers,
        getWhenOtherUserArrivesSubscribers,
        getUserTokens,
    } = await pushNotificationController(
        configuration.applePushNotifications.deviceTokenDBPath,
    );

    const pressBuzzer = async () => {
        for (const _ in [0, 1, 2, 3, 4, 5]) {
            await sleep(500);
            await buzzer.pressBuzzer();
        }
    };

    const handleDoorbellPress = createHandleDoorbellPress({
        getDoorbellRingSubscribers,
        getUserTokens,
        pressBuzzer,
        unlatchDoor: async () => {
            configuration.nuki.unlatch();
        },
        sendPush,
    });

    buzzer.registerDoorbellHandler(handleDoorbellPress);

    app.use(express.json())
        .all("*", (req, _res, next) => {
            if (!["HEAD /", "GET /"].includes(`${req.method} ${req.url}`)) {
                console.log(`🌎 ${req.ip} ${req.method} ${req.url}`);
            }
            next();
        })
        .post(
            ...authorized("/buzzer", async (_req, res) => {
                await pressBuzzer();
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/lock", async (_req, res) =>
                res.send(await configuration.nuki.lock()),
            ),
        )
        .post(
            ...authorized("/unlock", async (_req, res) =>
                res.send(await configuration.nuki.unlock()),
            ),
        )
        .post(
            ...authorized("/unlatch", async (_req, res) =>
                res.send(await configuration.nuki.unlatch()),
            ),
        )
        .get(
            ...authorized("/user", (req, res) => {
                const authHeader = splitAuthHeader(req.headers.authorization);
                if (authHeader === null) {
                    res.send({ sucess: false });
                    return;
                }
                // biome-ignore lint/style/noNonNullAssertion: code can't be reached when user doesn't exists
                const { secret: _secret, ...userInfo } = findUser(
                    authHeader.username,
                )!;
                res.send({ success: true, userInfo });
            }),
        )
        .get(
            ...authorized("/state", async (_req, res) =>
                res.send({
                    success: true,
                    doorlock: await configuration.nuki.getState(),
                    doorbellAction: getCurrentDoorbellAction(),
                }),
            ),
        )
        .post(
            ...authorized("/arrived", async (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const { displayName } = findUser(username)!;
                sendPush(
                    {
                        title: "Our Home",
                        body: `👋 ${displayName} ist da!`,
                        category: "buzzer",
                    },
                    await getWhenOtherUserArrivesSubscribers(username),
                );
                armForDoorBellAction({
                    type: "buzzer",
                    timeout: configuration.arrivalTimeout,
                    armedBy: username,
                });
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/arm/buzzer", (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                armForDoorBellAction({
                    type: "buzzer",
                    timeout: configuration.buzzerArmTimeout,
                    armedBy: username,
                });
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/arm/unlatch", (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                armForDoorBellAction({
                    type: "unlatch",
                    timeout: configuration.unlatchArmTimeout,
                    armedBy: username,
                });
                res.send({ success: true });
            }),
        )
        .get(
            ...authorized("/pushnotifications/:deviceToken", (req, res) => {
                res.send({ deviceToken: req.params.deviceToken });
            }),
        )
        .put(
            ...authorized("/pushnotifications/:deviceToken", async (req) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                const { types } = pushNotificationRegistration.parse(req.body);
                registerDevice(username, req.params.deviceToken, types);
                return { success: true };
            }),
        )
        .delete(
            ...authorized("/pushnotifications/:deviceToken", async (req) => {
                removeDevice(req.params.deviceToken);
                return { success: true };
            }),
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
