import express from "express";
import type { Express } from "express";
import {
    APNTokenDBController,
    pushNotificationRegistration,
} from "./APNTokenDb";
import {
    armForDoorBellAction,
    getCurrentDoorbellAction,
} from "./arrivedRecently";
import { splitAuthHeader } from "./auth";
import { authorized } from "./authorized";
import type { Configuration } from "./config";
import { createHandleDoorbellPress } from "./handleDoorbellPress";
import type { PushNotificationSender } from "./pushNotificationsSender";
import { sleep } from "./sleep";
import { findUser } from "./user";

export const apiServer = async (
    configuration: Configuration,
    sendPush: PushNotificationSender,
): Promise<Express> => {
    const buzzer = configuration.buzzer();
    const {
        registerDevice,
        removeDevice,
        getDoorbellRingSubscribers,
        getWhenOtherUserArrivesSubscribers,
        getUserTokens,
    } = await APNTokenDBController(
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

    return express()
        .use(express.json())
        .all("*", (req, _res, next) => {
            if (!["HEAD /", "GET /"].includes(`${req.method} ${req.url}`)) {
                console.log(`🌎 ${req.ip} ${req.method} ${req.url}`);
            }
            next();
        })
        .post(
            ...authorized("/buzzer", configuration, async (_req, res) => {
                await pressBuzzer();
                res.send({ success: true });
            }),
        )
        .post(
            ...authorized("/lock", configuration, async (_req, res) =>
                res.send(await configuration.nuki.lock()),
            ),
        )
        .post(
            ...authorized("/unlock", configuration, async (_req, res) =>
                res.send(await configuration.nuki.unlock()),
            ),
        )
        .post(
            ...authorized("/unlatch", configuration, async (_req, res) =>
                res.send(await configuration.nuki.unlatch()),
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
                    doorlock: await configuration.nuki.getState(),
                    doorbellAction: getCurrentDoorbellAction(),
                }),
            ),
        )
        .post(
            ...authorized("/arrived", configuration, async (req, res) => {
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const username = splitAuthHeader(
                    req.headers.authorization,
                )!.username;
                // biome-ignore lint/style/noNonNullAssertion: <explanation>
                const { displayName } = findUser(
                    username,
                    configuration.users,
                )!;
                sendPush(
                    {
                        title: "Our Home",
                        body: `👋 ${displayName} ist da!`,
                        category: "buzzer",
                    },
                    undefined,
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
            ...authorized("/arm/buzzer", configuration, (req, res) => {
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
            ...authorized("/arm/unlatch", configuration, (req, res) => {
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
        );
};
