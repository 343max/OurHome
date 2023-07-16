import { z } from "zod"

export const pushNotificationType = z.enum([
  "doorbellRing",
  "whenOtherUserArrives",
])
export type PushNotificationType = z.infer<typeof pushNotificationType>

export const pushNotificationRegistration = z.object({
  deviceToken: z.string(),
  types: z.array(pushNotificationType),
})
export type PushNotificationRegistration = z.infer<
  typeof pushNotificationRegistration
>
