import fs from "node:fs";
import { ApnsClient, Notification } from "apns2";
import type { DeviceTokenRow } from "./APNTokenDb";

export type PushNotificationSender = (
    alert: { title: string; body: string; category: string },
    data: Record<string, unknown> | undefined,
    devices: Pick<DeviceTokenRow, "deviceToken">[],
) => Promise<void>;

export const pushNotificationSender = ({
    teamId,
    signingKey,
    signingKeyId,
    topic,
}: {
    teamId: string;
    signingKey: string;
    signingKeyId: string;
    topic: string;
}): PushNotificationSender => {
    const keyBuffer = fs.readFileSync(signingKey);
    const apns = new ApnsClient({
        team: teamId,
        keyId: signingKeyId,
        defaultTopic: topic,
        signingKey: keyBuffer,
        keepAlive: false,
    });

    return async (
        {
            category,
            ...alert
        }: { title: string; body: string; category: string },
        data: Record<string, unknown> | undefined,
        devices: Pick<DeviceTokenRow, "deviceToken">[],
    ) => {
        console.log(
            `Sending push notifications: ${alert.title}: ${alert.body}`,
        );

        for (const device of devices) {
            try {
                await apns.send(
                    new Notification(device.deviceToken, {
                        alert,
                        category,
                        ...(data === undefined ? {} : data),
                    }),
                );
            } catch (error) {
                console.error(error);
            }
        }
    };
};
