import type { APNTokenDBController } from "./APNTokenDb";
import { defaultPlannedActions } from "./plannedActions";
import type { PushNotificationSender } from "./pushNotificationsSender";
import { sleep } from "./sleep";

type Options = Pick<
    Awaited<ReturnType<typeof APNTokenDBController>>,
    "getDoorbellRingSubscribers" | "getUserTokens"
> & {
    pressBuzzer: () => Promise<void>;
    unlatchDoor: () => Promise<void>;
    sendPush: PushNotificationSender;
};

export const createHandleDoorbellPress = ({
    getDoorbellRingSubscribers,
    getUserTokens,
    pressBuzzer,
    unlatchDoor,
    sendPush,
}: Options) => {
    return async (): Promise<"success" | "failure"> => {
        const action = defaultPlannedActions.getCurrentPlannedAction();
        if (action === null) {
            // if it wasn't one of us, send a notification
            sendPush(
                {
                    title: "Our Home",
                    body: "🔔 Ding! Dong!",
                    category: "buzzer",
                },
                undefined,
                await getDoorbellRingSubscribers(),
            );

            console.log("doorbell action not armed, doing nothing");
            return "failure";
        }

        switch (action.type) {
            case "buzzer":
                console.log("buzzer because the doorbell buzzer was armed");
                sendPush(
                    {
                        title: "Our Home",
                        body: "Buzzer wird gedrückt.",
                        category: "buzzer",
                    },
                    undefined,
                    await getUserTokens(action.armedBy),
                );
                await pressBuzzer();
                await sleep(500);
                defaultPlannedActions.resetDoorPlannedAction();
                return "success";
            case "unlatch":
                console.log("unlatching because the doorbell buzzer was armed");
                defaultPlannedActions.resetDoorPlannedAction();
                await unlatchDoor();
                return "success";
        }
    };
};
