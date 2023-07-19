import { env } from "./lib/env"
import { pushNotificationSender } from "./lib/pushNotificationsSender"

const sendPush = pushNotificationSender({
  teamId: env.APNS_TEAM_ID,
  signingKeyId: env.APNS_SIGNING_KEY_ID,
  signingKey: "./keys/AuthKey_C988QWV66B.p8",
  topic: env.APNS_TOPIC,
})

sendPush("Server started", [
  {
    deviceToken:
      "2d385a753e5d68b949451fe547e2b2c1df5fef1f9c1d52560a45c1e1b023f6d9",
  },
])
