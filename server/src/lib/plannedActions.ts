type DoorBellActionType = "buzzer" | "unlatch";
type DoorBellAction = {
    armedBy: string;
    timeout: number;
    type: DoorBellActionType;
};

export const plannedActions = (
    getTimeFn: () => number = () => new Date().getTime() / 1000,
) => {
    let doorBellAction: null | DoorBellAction = null;

    const isArmedDoorbellAction = (action: DoorBellAction | null): boolean =>
        action !== null && getTimeFn() < action.timeout;

    return {
        armForPlannedAction: ({ timeout, ...action }: DoorBellAction) => {
            doorBellAction = { timeout: getTimeFn() + timeout, ...action };
        },
        isArmedDoorbellAction,
        getCurrentDoorbellAction: (): DoorBellAction | null =>
            isArmedDoorbellAction(doorBellAction) ? doorBellAction : null,
        resetDoorBellAction: () => {
            doorBellAction = null;
        },
    };
};

export const defaultPlannedActions = plannedActions();
