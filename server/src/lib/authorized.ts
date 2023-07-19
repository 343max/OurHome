import { RequestHandler } from "express"
import { actionForPath } from "./action"
import { verifyAuth } from "./auth"

export const authorized = (
  path: string,
  handler: RequestHandler
): [string, RequestHandler] => {
  const action = actionForPath(path)
  if (action === undefined) {
    throw new Error(`unknown action for path ${path}`)
  }
  return [
    path,
    async (req, res, next) => {
      const authHeader = req.header("Authorization")
      const externHeader = req.header("x-forwarded-for")
      if (
        verifyAuth(
          authHeader,
          action,
          externHeader === undefined ? "local" : "remote"
        )
      ) {
        res.contentType("application/json; charset=UTF-8")
        await handler(req, res, next)
      } else {
        console.log("unauthorized")
        res.status(403)
        res.send({ success: false })
      }
    },
  ]
}
