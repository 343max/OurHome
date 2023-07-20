import { z } from "zod"
export const env = () =>
  z
    .object({
      DEVICE_TOKEN_DB_PATH: z.string().nonempty(),
      APNS_TEAM_ID: z.string().nonempty(),
      APNS_SIGNING_KEY_ID: z.string().nonempty(),
      APNS_SIGNING_KEY: z.string().nonempty(),
      APNS_TOPIC: z.string().nonempty(),
      APNS_PRODUCTION: z.union([z.literal("1"), z.literal("0")]).optional(),
      DISABLE_AUTH: z.literal("1").optional(),
    })
    .parse(process.env)
