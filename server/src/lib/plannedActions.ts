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

    const isArmedAction = (action: DoorBellAction | null): boolean =>
        action !== null && getTimeFn() < action.timeout;

    return {
        armForPlannedAction: ({ timeout, ...action }: DoorBellAction) => {
            doorBellAction = { timeout: getTimeFn() + timeout, ...action };
        },
        isArmedAction: isArmedAction,
        getCurrentPlannedAction: (): DoorBellAction | null =>
            isArmedAction(doorBellAction) ? doorBellAction : null,
        resetDoorPlannedAction: () => {
            doorBellAction = null;
        },
    };
};

export const defaultPlannedActions = plannedActions();
