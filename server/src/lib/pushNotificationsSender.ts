import { DeviceTokenRow } from "./pushNotifications"
import PushNotifications from "node-pushnotifications"

export const pushNotificationSender = ({
  teamId,
  signingKey,
  signingKeyId,
  topic,
}: {
  teamId: string
  signingKey: string
  signingKeyId: string
  topic: string
}) => {
  const apns = new PushNotifications({
    apn: { token: { teamId, key: signingKey, keyId: signingKeyId } },
  })

  return async (
    message: string,
    devices: Pick<DeviceTokenRow, "deviceToken">[]
  ) => {
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
}
