import { dumpInviteLinks, findUser } from "./lib/user"
import { getRuntimeConfig } from "./lib/config"
import { configuration } from "./secrets"
import { splitAuthHeader } from "./lib/auth"
import {
  getCurrentDoorbellAction,
  resetDoorBellAction,
  armForDoorBellAction,
} from "./lib/arrivedRecently"
import { buildInfo } from "./lib/buildinfo"
import express from "express"
import {
  pushNotificationRegistration,
  pushNotificationController,
} from "./lib/pushNotifications"
import { env } from "./lib/env"
import { authorized } from "./lib/authorized"
import { pushNotificationSender } from "./lib/pushNotificationsSender"
import { sleep } from "./lib/sleep"

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
  } = await pushNotificationController(env().DEVICE_TOKEN_DB_PATH)

  const sendPush = pushNotificationSender({
    teamId: env().APNS_TEAM_ID,
    signingKeyId: env().APNS_SIGNING_KEY_ID,
    signingKey: env().APNS_SIGNING_KEY,
    topic: env().APNS_TOPIC,
    production: env().APNS_PRODUCTION === "1",
  })

  await sendPush(
    { title: "Our Home", body: "🌳 Server started", category: "buzzer" },
    await getDoorbellRingSubscribers()
  )

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
    .post(
      ...authorized("/lock", async (_req, res) =>
        res.send(await configuration.nuki.lock())
      )
    )
    .post(
      ...authorized("/unlock", async (_req, res) =>
        res.send(await configuration.nuki.unlock())
      )
    )
    .post(
      ...authorized("/unlatch", async (_req, res) =>
        res.send(await configuration.nuki.unlatch())
      )
    )
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
            body: `👋 ${displayName} arrived!`,
            category: "buzzer",
          },
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
        sendPush(
          {
            title: "Our Home",
            body: "🔔 Ding! Dong!",
            category: "buzzer",
          },
          await getDoorbellRingSubscribers()
        )

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
