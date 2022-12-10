const getTime = () => new Date().getTime() / 1000

type DoorBellActionType = "buzzer" | "unlatch"
type DoorBellAction = { timeout: number; type: DoorBellActionType }

let doorBellAction: null | DoorBellAction = null

export const armForDoorBellAction = (type: DoorBellActionType) => {
  doorBellAction = { timeout: getTime() + 3 * 60, type }
}

export const getCurrentDoorbellAction = (): DoorBellAction | null =>
  doorBellAction !== null && getTime() - doorBellAction.timeout
    ? doorBellAction
    : null

export const resetDoorBellAction = () => {
  doorBellAction = null
}
