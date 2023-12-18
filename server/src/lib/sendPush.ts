import { env } from "./env"
import { pushNotificationSender } from "./pushNotificationsSender"

export const sendPush = pushNotificationSender({
  teamId: env().APNS_TEAM_ID,
  signingKeyId: env().APNS_SIGNING_KEY_ID,
  signingKey: env().APNS_SIGNING_KEY,
  topic: env().APNS_TOPIC,
  production: env().APNS_PRODUCTION === "1",
})
