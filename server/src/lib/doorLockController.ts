import type { Buzzer } from "./buzzer";
import type { Configuration } from "./config";
import type { PlannedActions } from "./plannedActions";
import { sleep } from "./sleep";

export const setupDoorLockController = (
    plannedActions: PlannedActions,
    {
        buzzer,
        nuki,
        ...configuration
    }: Pick<
        Configuration,
        | "nuki"
        | "users"
        | "buzzerArmTimeout"
        | "unlatchArmTimeout"
        | "arrivalTimeout"
    > & { buzzer: ReturnType<Buzzer> },
    {
        handleAnonymousDoorbellPress,
        handleUnlatchingDoorBecauseOfRing,
        handleUserArrived,
    }: {
        handleAnonymousDoorbellPress: () => Promise<void>;
        handleUnlatchingDoorBecauseOfRing: (armedBy: string) => Promise<void>;
        handleUserArrived: (username: string) => Promise<void>;
    },
) => {
    const pressBuzzer = async () => {
        for (const _ in [0, 1, 2, 3, 4, 5]) {
            await sleep(500);
            await buzzer.pressBuzzer();
        }
    };

    const handleDoorbellPress = async (): Promise<"success" | "failure"> => {
        const action = plannedActions.getCurrentPlannedAction();
        if (action === null) {
            // if it wasn't one of us, send a notification
            await handleAnonymousDoorbellPress();

            console.log("doorbell action not armed, doing nothing");
            return "failure";
        }

        switch (action.type) {
            case "buzzer":
                console.log("buzzer because the doorbell buzzer was armed");

                await handleUnlatchingDoorBecauseOfRing(action.armedBy);

                await pressBuzzer();
                await sleep(500);
                plannedActions.resetDoorPlannedAction();
                return "success";
            case "unlatch":
                console.log("unlatching because the doorbell buzzer was armed");
                plannedActions.resetDoorPlannedAction();
                await nuki.unlatch();
                return "success";
        }
    };

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
            handleUserArrived(username);

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
