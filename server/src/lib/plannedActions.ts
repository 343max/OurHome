type DoorBellActionType = "buzzer" | "unlatch";
type DoorBellAction = {
    armedBy: string;
    timeout: number;
    type: DoorBellActionType;
};

type GetTimeFn = () => number;

export const isArmedAction = (
    action: DoorBellAction | null,
    getTimeFn: GetTimeFn,
): boolean => action !== null && getTimeFn() < action.timeout;

export const setupPlannedActions = (
    getTimeFn: GetTimeFn = () => new Date().getTime() / 1000,
) => {
    let doorBellAction: null | DoorBellAction = null;

    return {
        armForPlannedAction: ({ timeout, ...action }: DoorBellAction) => {
            doorBellAction = { timeout: getTimeFn() + timeout, ...action };
        },

        getCurrentPlannedAction: (): DoorBellAction | null =>
            isArmedAction(doorBellAction, getTimeFn) ? doorBellAction : null,

        resetDoorPlannedAction: () => {
            doorBellAction = null;
        },
    };
};

export const defaultPlannedActions = setupPlannedActions();

export type PlannedActions = ReturnType<typeof setupPlannedActions>;
