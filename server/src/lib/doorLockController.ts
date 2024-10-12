import type { APNTokenDBControllerFunctions } from "./APNTokenDb";
import type { Configuration } from "./config";
import { createHandleDoorbellPress } from "./handleDoorbellPress";
import type { PlannedActions } from "./plannedActions";
import type { pushNotificationSender } from "./pushNotificationsSender";
import { sleep } from "./sleep";
import { findUser } from "./user";

export const setupDoorLockController = (
    plannedActions: PlannedActions,
    { nuki, ...configuration }: Configuration,
    sendPush: ReturnType<typeof pushNotificationSender>,
    {
        getDoorbellRingSubscribers,
        getUserTokens,
        getWhenOtherUserArrivesSubscribers,
    }: Pick<
        APNTokenDBControllerFunctions,
        | "getDoorbellRingSubscribers"
        | "getUserTokens"
        | "getWhenOtherUserArrivesSubscribers"
    >,
) => {
    const buzzer = configuration.buzzer();

    const pressBuzzer = async () => {
        for (const _ in [0, 1, 2, 3, 4, 5]) {
            await sleep(500);
            await buzzer.pressBuzzer();
        }
    };

    const handleDoorbellPress = createHandleDoorbellPress({
        getDoorbellRingSubscribers,
        getUserTokens,
        pressBuzzer,
        unlatchDoor: async () => {
            nuki.unlatch();
        },
        sendPush,
    });

    buzzer.registerDoorbellHandler(handleDoorbellPress);

    return {
        pressBuzzer,
        lockDoor: async () => {
            return nuki.lock();
        },
        unlockDoor: async () => {
            return nuki.unlock();
        },
        unlatchDoor: async () => {
            return nuki.unlatch();
        },
        getNukiState: async () => {
            return nuki.getState();
        },
        userArrived: async (username: string) => {
            const { displayName } = findUser(username, configuration.users) ?? {
                displayName: undefined,
            };

            sendPush(
                {
                    title: "Our Home",
                    body: `👋 ${displayName} ist da!`,
                    category: "buzzer",
                },
                undefined,
                await getWhenOtherUserArrivesSubscribers(username),
            );

            plannedActions.armForPlannedAction({
                type: "buzzer",
                timeout: configuration.arrivalTimeout,
                armedBy: username,
            });
        },
        armBuzzer: async (armedBy: string) => {
            plannedActions.armForPlannedAction({
                type: "buzzer",
                timeout: configuration.buzzerArmTimeout,
                armedBy,
            });
        },
        armUnlatch: async (armedBy: string) => {
            plannedActions.armForPlannedAction({
                type: "unlatch",
                timeout: configuration.unlatchArmTimeout,
                armedBy,
            });
        },
    };
};
