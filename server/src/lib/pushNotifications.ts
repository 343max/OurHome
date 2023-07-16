import { z } from "zod"
import { Database } from "bun:sqlite"

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

export const pushNotificationController = (path: string) => {
  const db = new Database(path, { create: true, readwrite: true })

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

  const sendPush = (message: string, devices: DeviceTokenRow[]) => {
    for (const device of devices) {
      console.log(`Sending push notification to ${device.username}: ${message}`)
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
