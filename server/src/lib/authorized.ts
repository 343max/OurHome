import { RequestHandler } from "express"
import { RouteParameters } from "express-serve-static-core"
import { actionForPath } from "./action"
import { verifyAuth } from "./auth"
import { ParsedQs } from "qs"

export const authorized = <
  Path extends string,
  P = RouteParameters<Path>,
  ResBody = any,
  ReqBody = any,
  ReqQuery = ParsedQs,
  LocalsObj extends Record<string, any> = Record<string, any>
>(
  path: Path,
  handler: RequestHandler<P, ResBody, ReqBody, ReqQuery, LocalsObj>
): [string, RequestHandler<P, ResBody | { success: false }, ReqBody, ReqQuery, LocalsObj>] => {
  const action = actionForPath(path)
  if (action === undefined) {
    throw new Error(`unknown action for path ${path}`)
  }
  return [
    path,
    async (req, res, next) => {
      const authHeader = req.header("Authorization")
      if (verifyAuth(authHeader, action)) {
        res.contentType("application/json; charset=UTF-8")
        await handler(req, res, next)
      } else {
        console.log("unauthorized")
        res.status(403)
        res.send({ success: false } as const)
      }
    },
  ]
}
