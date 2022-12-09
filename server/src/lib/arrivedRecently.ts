const getTime = () => new Date().getTime() / 1000

type DoorBellAction = "buzzer" | "unlatch"

let lastArrival: null | { arrival: number; action: DoorBellAction }

export const armForDoorBellAction = (action: DoorBellAction) => {
  lastArrival = { arrival: getTime(), action }
}

export const getDoorbellAction = (): DoorBellAction | null =>
  lastArrival !== null && getTime() - lastArrival.arrival < 3 * 60
    ? lastArrival.action
    : null

export const resetDoorBellAction = () => {
  lastArrival = null
}
