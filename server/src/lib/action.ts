export const actions = [
  "/lock",
  "/unlock",
  "/unlatch",
  "/buzzer",
  "/state",
  "/user",
  "/arrived",
  "/doorbell",
  "/arm/buzzer",
  "/arm/unlatch",
  "/pushnotifications",
] as const

export type Action = (typeof actions)[number]

export const actionForPath = (path: string): Action | undefined => {
  return actions.find((action) => path.startsWith(action))
}
