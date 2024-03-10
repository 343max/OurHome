import { dumpInviteLinks, findUser } from "./lib/user"
import { getRuntimeConfig } from "./lib/config"
import { configuration } from "./secrets"
import { splitAuthHeader } from "./lib/auth"
import { getCurrentDoorbellAction, armForDoorBellAction } from "./lib/arrivedRecently"
import { buildInfo } from "./lib/buildinfo"
import express from "express"
import { pushNotificationRegistration, pushNotificationController } from "./lib/pushNotifications"
import { env } from "./lib/env"
import { authorized } from "./lib/authorized"
import { sleep } from "./lib/sleep"
import { sendPush } from "./lib/sendPush"
import { createHandleDoorbellPress } from "./lib/handleDoorbellPress"

const app = express()

if (getRuntimeConfig().ignoreAuthentication) {
  console.log("⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️")
}

const port = parseInt(`${process.env["HTTP_PORT"]}`, 10)

console.log(`🌳 server running at http://localhost:${port}/ 🌳`)
console.log(`👷 build date: ${buildInfo.date}`)

dumpInviteLinks()

const main = async () => {
  const buzzer = configuration.buzzer()
  const {
    registerDevice,
    removeDevice,
    getDoorbellRingSubscribers,
    getWhenOtherUserArrivesSubscribers,
    getUserTokens,
  } = await pushNotificationController(env().DEVICE_TOKEN_DB_PATH)

  const pressBuzzer = async () => {
    for (const _ in [0, 1, 2, 3, 4, 5]) {
      await sleep(500)
      await buzzer.pressBuzzer()
    }
  }

  const handleDoorbellPress = createHandleDoorbellPress({
    getDoorbellRingSubscribers,
    getUserTokens,
    pressBuzzer,
    unlatchDoor: async () => {
      configuration.nuki.unlatch()
    },
  })

  buzzer.registerDoorbellHandler(handleDoorbellPress)

  app
    .use(express.json())
    .all("*", (req, _res, next) => {
      if (!["HEAD /", "GET /"].includes(`${req.method} ${req.url}`)) {
        console.log(`🌎 ${req.ip} ${req.method} ${req.url}`)
      }
      next()
    })
    .post(
      ...authorized("/buzzer", async (_req, res) => {
        await pressBuzzer()
        res.send({ success: true })
      })
    )
    .post(...authorized("/lock", async (_req, res) => res.send(await configuration.nuki.lock())))
    .post(...authorized("/unlock", async (_req, res) => res.send(await configuration.nuki.unlock())))
    .post(...authorized("/unlatch", async (_req, res) => res.send(await configuration.nuki.unlatch())))
    .get(
      ...authorized("/user", (req, res) => {
        const authHeader = splitAuthHeader(req.headers.authorization)
        if (authHeader === null) {
          res.send({ sucess: false })
          return
        }
        const { secret: _secret, ...userInfo } = findUser(authHeader.username)!
        res.send({ success: true, userInfo })
      })
    )
    .get(
      ...authorized("/state", async (_req, res) =>
        res.send({
          success: true,
          doorlock: await configuration.nuki.getState(),
          doorbellAction: getCurrentDoorbellAction(),
        })
      )
    )
    .post(
      ...authorized("/arrived", async (req, res) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        const { displayName } = findUser(username)!
        sendPush(
          {
            title: "Our Home",
            body: `👋 ${displayName} ist da!`,
            category: "buzzer",
          },
          await getWhenOtherUserArrivesSubscribers(username)
        )
        armForDoorBellAction({
          type: "buzzer",
          timeout: configuration.arrivalTimeout,
          armedBy: username,
        })
        res.send({ success: true })
      })
    )
    .post(
      ...authorized("/arm/buzzer", (req, res) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        armForDoorBellAction({
          type: "buzzer",
          timeout: configuration.buzzerArmTimeout,
          armedBy: username,
        })
        res.send({ success: true })
      })
    )
    .post(
      ...authorized("/arm/unlatch", (req, res) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        armForDoorBellAction({
          type: "unlatch",
          timeout: configuration.unlatchArmTimeout,
          armedBy: username,
        })
        res.send({ success: true })
      })
    )
    .get(
      ...authorized("/pushnotifications/:deviceToken", (req, res) => {
        res.send({ deviceToken: req.params.deviceToken })
      })
    )
    .put(
      ...authorized("/pushnotifications/:deviceToken", async (req) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        const { types } = pushNotificationRegistration.parse(req.body)
        registerDevice(username, req.params.deviceToken, types)
        return { success: true }
      })
    )
    .delete(
      ...authorized("/pushnotifications/:deviceToken", async (req) => {
        removeDevice(req.params.deviceToken)
        return { success: true }
      })
    )
    .get("/", (_req, res) => res.send({ success: true, message: "please leave me alone" }))
    .head("/", (_req, res) => res.send({ success: true, message: "please leave me alone" }))
    .get("/.well-known/apple-app-site-association", (_req, res) =>
      res.send({
        applinks: {
          details: [
            {
              appID: "ATMW4AU45H.de.343max.ourhome.Our-Home",
              paths: ["/*"],
            },
            {
              appID: "ATMW4AU45H.de.343max.OurHome.OHWatch.watchkitapp",
              paths: ["/*"],
            },
          ],
        },
      })
    )
    .listen(port)
}

main()
