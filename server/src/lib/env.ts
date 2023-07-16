import { z } from "zod"
export const env = z
  .object({ DEVICE_TOKEN_DB_PATH: z.string().nonempty() })
  .parse(process.env)
