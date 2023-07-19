import { z } from "zod"
import { Database } from "bun:sqlite"
import PushNotifications from "node-pushnotifications"

export const pushNotificationType = z.enum([
  "doorbellRing",
  "whenOtherUserArrives",
])
export type PushNotificationType = z.infer<typeof pushNotificationType>

export const pushNotificationRegistration = z.object({
  types: z.array(pushNotificationType),
})

export type PushNotificationRegistration = z.infer<
  typeof pushNotificationRegistration
>

const deviceTokenRow = z.object({
  deviceToken: z.string(),
  username: z.string(),
})

export type DeviceTokenRow = z.infer<typeof deviceTokenRow>

export const pushNotificationController = (
  databasePath: string,
  {
    teamId,
    signingKey,
    signingKeyId,
    topic,
  }: { teamId: string; signingKey: string; signingKeyId: string; topic: string }
) => {
  const db = new Database(databasePath, { create: true, readwrite: true })
  const apns = new PushNotifications({
    apn: { token: { teamId, key: signingKey, keyId: signingKeyId } },
  })

  const prepare = () => {
    db.query(
      `CREATE TABLE IF NOT EXISTS "deviceTokens" (
        "deviceToken" TEXT NOT NULL,
        "username" text NOT NULL,
        "notificationTypes" text NOT NULL,
        PRIMARY KEY (deviceToken)
    );`
    ).run()
  }

  prepare()

  const parseRows = (rows: any[]) => z.array(deviceTokenRow).parse(rows)

  const registerDevice = (
    user: string,
    token: string,
    types: PushNotificationType[]
  ) => {
    db.prepare(
      `INSERT OR REPLACE INTO deviceTokens (deviceToken, username, notificationTypes) VALUES (?, ?, ?)`
    ).run(token, user, JSON.stringify(types))
  }

  const removeDevice = (token: string) => {
    db.prepare("DELETE FROM deviceTokens WHERE deviceToken = ?").run(token)
  }

  const getDoorbellRingSubscribers = (): DeviceTokenRow[] => {
    return parseRows(
      db
        .query(
          'SELECT * FROM deviceTokens WHERE notificationTypes LIKE "%doorbellRing%"'
        )
        .all()
    )
  }

  const getWhenOtherUserArrivesSubscribers = (
    arrivingUser: string
  ): DeviceTokenRow[] => {
    return parseRows(
      db
        .query(
          `SELECT * FROM 
              deviceTokens
            WHERE
              notificationTypes LIKE "%whenOtherUserArrives%" AND
              username != ?`
        )
        .all(arrivingUser)
    )
  }

  const sendPush = async (message: string, devices: DeviceTokenRow[]) => {
    console.log(`Sending push notifications: ${message}`)
    const tokens = devices.map((d) => d.deviceToken)

    try {
      await apns.send(tokens, {
        title: "Doorbell",
        body: message,
        topic,
      })
    } catch (error) {
      console.error(error)
    }
  }

  return {
    prepare,
    registerDevice,
    removeDevice,
    getDoorbellRingSubscribers,
    getWhenOtherUserArrivesSubscribers,
    sendPush,
  }
}
