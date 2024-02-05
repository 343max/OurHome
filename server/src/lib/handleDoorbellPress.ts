import { getCurrentDoorbellAction, resetDoorBellAction } from "./arrivedRecently"
import { pushNotificationController } from "./pushNotifications"
import { sendPush } from "./sendPush"
import { sleep } from "./sleep"

type Options = Pick<
  Awaited<ReturnType<typeof pushNotificationController>>,
  "getDoorbellRingSubscribers" | "getUserTokens"
> & {
  pressBuzzer: () => Promise<void>
  unlatchDoor: () => Promise<void>
}

export const createHandleDoorbellPress = ({
  getDoorbellRingSubscribers,
  getUserTokens,
  pressBuzzer,
  unlatchDoor,
}: Options) => {
  return async (): Promise<"success" | "failure"> => {
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
      return "failure"
    }

    switch (action.type) {
      case "buzzer":
        console.log("buzzer because the doorbell buzzer was armed")
        sendPush(
          {
            title: "Our Home",
            body: "Buzzer wird gedrückt.",
            category: "buzzer",
          },
          await getUserTokens(action.armedBy)
        )
        await pressBuzzer()
        await sleep(500)
        resetDoorBellAction()
        return "success"
      case "unlatch":
        console.log("unlatching because the doorbell buzzer was armed")
        resetDoorBellAction()
        await unlatchDoor()
        return "success"
    }
  }
}
