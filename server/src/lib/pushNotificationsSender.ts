import PushNotifications from "node-pushnotifications"
import { DeviceTokenRow } from "./pushNotifications"

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
    data: { title: string; body: string; category: string },
    devices: Pick<DeviceTokenRow, "deviceToken">[]
  ) => {
    console.log(`Sending push notifications: ${data.title}: ${data.body}`)

    for (const device of devices) {
      try {
        await apns.send(device.deviceToken, {
          ...data,
          topic,
        })
      } catch (error) {
        console.error(error)
      }
    }
  }
}
