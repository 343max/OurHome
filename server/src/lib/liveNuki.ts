import { Nuki, NukiSmartLockConfig } from "./nuki.ts"

type LiveNukiConfiguration = {
  host: string
  port: number
  token: string
  deviceId: number
}

export const getNukiUrl = (
  action: string,
  { host, port, token, deviceId }: LiveNukiConfiguration,
  params: { [key: string]: string | number }
): string => {
  const allParams = Object.entries({ token, nukiId: deviceId, ...params })
    .map(([key, value]) => `${key}=${value}`)
    .join("&")
  return `http://${host}:${port}/${action}?${allParams}`
}

export const getNukiRequest = (
  action: string,
  config: LiveNukiConfiguration,
  params: { [key: string]: string | number } = {}
): Request => {
  return new Request(getNukiUrl(action, config, params), {
    headers: { "Content-Type": "application/json", Accept: "application/json" },
  })
}

export const liveNuki = (config: LiveNukiConfiguration): Nuki => ({
  lock: async () => (await fetch(getNukiRequest("lock", config))).json(),
  unlock: async () => (await fetch(getNukiRequest("unlock", config))).json(),
  unlatch: async () =>
    (await fetch(getNukiRequest("lockAction", config, { action: 3 }))).json(),
  getState: async (): Promise<NukiSmartLockConfig> =>
    (await fetch(getNukiRequest("lockState", config))).json(),
})
