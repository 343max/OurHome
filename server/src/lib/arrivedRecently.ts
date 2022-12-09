const getTime = () => new Date().getTime() / 1000

type DoorBellAction = "buzzer" | "unlatch"
type DoorBellActionWithTimeout = { timeout: number; action: DoorBellAction }

let doorBellAction: null | DoorBellActionWithTimeout = null

export const armForDoorBellAction = (action: DoorBellAction) => {
  doorBellAction = { timeout: getTime() + 3 * 60, action }
}

export const getCurrentDoorbellAction = (): DoorBellActionWithTimeout | null =>
  doorBellAction !== null && getTime() - doorBellAction.timeout
    ? doorBellAction
    : null

export const resetDoorBellAction = () => {
  doorBellAction = null
}
