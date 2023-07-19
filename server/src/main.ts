import { dumpInviteLinks, findUser } from "./lib/user.ts"
import { getRuntimeConfig } from "./lib/config.ts"
import { configuration } from "./secrets.ts"
import { splitAuthHeader } from "./lib/auth.ts"
import {
  getCurrentDoorbellAction,
  resetDoorBellAction,
  armForDoorBellAction,
} from "./lib/arrivedRecently.ts"
import { buildInfo } from "./lib/buildinfo.ts"
import express from "express"
import {
  pushNotificationRegistration,
  pushNotificationController,
} from "./lib/pushNotifications"
import { env } from "./lib/env.ts"
import { authorized } from "./lib/authorized.ts"
import { pushNotificationSender } from "./lib/pushNotificationsSender"
import { sleep } from "./lib/sleep.ts"

const app = express()

if (getRuntimeConfig().ignoreAuthentication) {
  console.log(
    "⚠️ Authentication overwritten & ignored! Don't run in production! ⚠️"
  )
}

const port = 4278

console.log(`🌳 server running at http://localhost:${port}/ 🌳`)
console.log(`👷 build date: ${buildInfo.date}`)

dumpInviteLinks()

const main = async () => {
  const {
    registerDevice,
    removeDevice,
    getDoorbellRingSubscribers,
    getWhenOtherUserArrivesSubscribers,
  } = await pushNotificationController(env.DEVICE_TOKEN_DB_PATH)

  const sendPush = pushNotificationSender({
    teamId: env.APNS_TEAM_ID,
    signingKeyId: env.APNS_SIGNING_KEY_ID,
    signingKey: env.APNS_SIGNING_KEY,
    topic: env.APNS_TOPIC,
  })

  sendPush("Server started", [
    {
      deviceToken:
        "2d385a753e5d68b949451fe547e2b2c1df5fef1f9c1d52560a45c1e1b023f6d9",
    },
  ])

  const pressBuzzer = async () => {
    for (const _ in [0, 1, 2, 3, 4, 5]) {
      await sleep(500)
      await configuration.buzzer.pressBuzzer()
    }
  }

  app
    .use(express.json())
    .all("*", (req, _res, next) => {
      console.log(`🌎 ${req.ip} ${req.method} ${req.url}`)
      next()
    })
    .post(
      ...authorized("/buzzer", async (_req, res) => {
        await pressBuzzer()
        res.send({ success: true })
      })
    )
    .post(...authorized("/lock", () => configuration.nuki.lock()))
    .post(...authorized("/unlock", () => configuration.nuki.unlock()))
    .post(...authorized("/unlatch", () => configuration.nuki.unlatch()))
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
      ...authorized("/state", async () => ({
        success: true,
        doorlock: await configuration.nuki.getState(),
        doorbellAction: getCurrentDoorbellAction(),
      }))
    )
    .post(
      ...authorized("/arrived", async (req, res) => {
        const username = splitAuthHeader(req.headers.authorization)!.username
        sendPush(
          `👋 ${username} arrived!`,
          await getWhenOtherUserArrivesSubscribers(username)
        )
        armForDoorBellAction("buzzer", configuration.arrivalTimeout)
        res.send({ success: true })
      })
    )
    .post(
      ...authorized("/arm/buzzer", (_req, res) => {
        armForDoorBellAction("buzzer", configuration.buzzerArmTimeout)
        res.send({ success: true })
      })
    )
    .post(
      ...authorized("/arm/unlatch", (_req, res) => {
        armForDoorBellAction("unlatch", configuration.unlatchArmTimeout)
        res.send({ success: true })
      })
    )
    .post("/doorbell", async (_req, res, _next) => {
      const action = getCurrentDoorbellAction()
      if (action === null) {
        // if it wasn't one of us, send a notification
        sendPush("🔔 Ding! Dong!", await getDoorbellRingSubscribers())

        console.log("doorbell action not armed, doing nothing")
        res.send({ success: false })
        return
      }

      switch (action.type) {
        case "buzzer":
          console.log("buzzer because the doorbell buzzer was armed")
          await pressBuzzer()
          await sleep(500)
          resetDoorBellAction()
          res.send({ success: true })
          break
        case "unlatch":
          console.log("unlatching because the doorbell buzzer was armed")
          resetDoorBellAction()
          await configuration.nuki.unlatch()
          break
      }
    })
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
        console.log([username, req.params.deviceToken, types])
        return { success: true }
      })
    )
    .delete(
      ...authorized("/pushnotifications/:deviceToken", async (req) => {
        removeDevice(req.params.deviceToken)
        return { success: true }
      })
    )
    .get("/", (_req, res) =>
      res.send({ success: true, message: "please leave me alone" })
    )
    .head("/", (_req, res) =>
      res.send({ success: true, message: "please leave me alone" })
    )
    .listen(port)
}

main()
