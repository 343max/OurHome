import { mergedPromises } from "./mergedPromises";
import {
    type Nuki,
    type NukiResponse,
    type NukiSmartLockConfig,
    nukiSmartLockConfig,
} from "./nuki";
import { nukiResponse } from "./nuki";

type LiveNukiConfiguration = {
    host: string;
    port: number;
    token: string;
    deviceId: number;
};

export const getNukiUrl = (
    action: string,
    { host, port, token, deviceId }: LiveNukiConfiguration,
    params: Record<string, string | number>,
): string => {
    const allParams = Object.entries({ token, nukiId: deviceId, ...params })
        .map(([key, value]) => `${key}=${value}`)
        .join("&");
    return `http://${host}:${port}/${action}?${allParams}`;
};

export const getNukiRequest = (
    action: string,
    config: LiveNukiConfiguration,
    params: Record<string, string | number> = {},
): Request => {
    return new Request(getNukiUrl(action, config, params), {
        headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
        },
    });
};

const mergedGetLockStateState = mergedPromises<any>(null);

const sendNukiRequest = async (
    ...args: Parameters<typeof getNukiRequest>
): Promise<NukiResponse | { success: false }> => {
    try {
        const response = await fetch(getNukiRequest(...args));
        return nukiResponse.parse(await response.json());
    } catch (error) {
        return { success: false };
    }
};

export const liveNuki = (config: LiveNukiConfiguration): Nuki => ({
    lock: async () => sendNukiRequest("lock", config),
    unlock: async () => sendNukiRequest("unlock", config),
    unlatch: async () => sendNukiRequest("lockAction", config, { action: 3 }),
    getState: async (): Promise<NukiSmartLockConfig | null> => {
        try {
            return nukiSmartLockConfig.parse(
                await mergedGetLockStateState(async () =>
                    (await fetch(getNukiRequest("lockState", config))).json(),
                ),
            );
        } catch (error) {
            console.error(error);
            return null;
        }
    },
});
