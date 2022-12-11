const getTime = () => new Date().getTime() / 1000

type DoorBellActionType = "buzzer" | "unlatch"
type DoorBellAction = { timeout: number; type: DoorBellActionType }

let doorBellAction: null | DoorBellAction = null

export const armForDoorBellAction = (
  type: DoorBellActionType,
  timeout: number
) => {
  doorBellAction = { timeout: getTime() + timeout, type }
}

export const isArmedDoorbellAction = (action: DoorBellAction | null): boolean =>
  action !== null && getTime() < action.timeout

export const getCurrentDoorbellAction = (): DoorBellAction | null =>
  isArmedDoorbellAction(doorBellAction) ? doorBellAction : null

export const resetDoorBellAction = () => {
  doorBellAction = null
}
