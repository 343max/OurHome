import { AsyncDatabase } from "promised-sqlite3";
import { z } from "zod";

export const pushNotificationType = z.enum([
    "doorbellRing",
    "whenOtherUserArrives",
]);
export type PushNotificationType = z.infer<typeof pushNotificationType>;

export const pushNotificationRegistration = z.object({
    types: z.array(pushNotificationType),
});

export type PushNotificationRegistration = z.infer<
    typeof pushNotificationRegistration
>;

const deviceTokenRow = z.object({
    deviceToken: z.string(),
    username: z.string(),
});

export type DeviceTokenRow = z.infer<typeof deviceTokenRow>;

export const APNTokenDBController = async (databasePath: string) => {
    const db = await AsyncDatabase.open(databasePath);

    const prepare = async () => {
        await db.run(
            `CREATE TABLE IF NOT EXISTS "deviceTokens" (
                "deviceToken" TEXT NOT NULL,
                "username" text NOT NULL,
                "notificationTypes" text NOT NULL,
                PRIMARY KEY (deviceToken)
            );`,
        );
    };

    await prepare();

    const parseRows = (rows: any[]) => z.array(deviceTokenRow).parse(rows);

    const registerDevice = async (
        user: string,
        token: string,
        types: PushNotificationType[],
    ) => {
        await db.run("DELETE FROM deviceTokens WHERE deviceToken = ?", token);
        await db.run(
            "INSERT OR REPLACE INTO deviceTokens (deviceToken, username, notificationTypes) VALUES (?, ?, ?)",
            [token, user, JSON.stringify(types)],
        );
    };

    const removeDevice = async (token: string) => {
        await db.run("DELETE FROM deviceTokens WHERE deviceToken = ?", token);
    };

    const getDoorbellRingSubscribers = async (): Promise<DeviceTokenRow[]> => {
        return parseRows(
            await db.all(
                'SELECT * FROM deviceTokens WHERE notificationTypes LIKE "%doorbellRing%"',
            ),
        );
    };

    const getWhenOtherUserArrivesSubscribers = async (
        arrivingUser: string,
    ): Promise<DeviceTokenRow[]> => {
        return parseRows(
            await db.all(
                `SELECT * FROM 
              deviceTokens
            WHERE
              notificationTypes LIKE "%whenOtherUserArrives%" AND
              username != ?`,
                arrivingUser,
            ),
        );
    };

    const getUserTokens = async (
        username: string,
    ): Promise<DeviceTokenRow[]> => {
        return parseRows(
            await db.all(
                `SELECT * FROM 
              deviceTokens
            WHERE
              username == ?`,
                username,
            ),
        );
    };

    return {
        prepare,
        registerDevice,
        removeDevice,
        getDoorbellRingSubscribers,
        getWhenOtherUserArrivesSubscribers,
        getUserTokens,
    };
};
