import PushNotifications from "node-pushnotifications";
import type { DeviceTokenRow } from "./APNTokenDb";

export type PushNotificationSender = (
    data: { title: string; body: string; category: string },
    devices: Pick<DeviceTokenRow, "deviceToken">[],
) => Promise<void>;

export const pushNotificationSender = ({
    teamId,
    signingKey,
    signingKeyId,
    topic,
    production,
}: {
    teamId: string;
    signingKey: string;
    signingKeyId: string;
    topic: string;
    production: boolean;
}): PushNotificationSender => {
    const apns = new PushNotifications({
        apn: {
            token: { teamId, key: signingKey, keyId: signingKeyId },
            production,
        },
    });

    return async (
        data: { title: string; body: string; category: string },
        devices: Pick<DeviceTokenRow, "deviceToken">[],
    ) => {
        console.log(`Sending push notifications: ${data.title}: ${data.body}`);

        for (const device of devices) {
            try {
                await apns.send(device.deviceToken, {
                    ...data,
                    topic,
                });
            } catch (error) {
                console.error(error);
            }
        }
    };
};
