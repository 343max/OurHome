import { createHash } from "node:crypto";
import type { Action } from "./action";
import type { Configuration } from "./config";
import { type Permission, type Permissions, findUser } from "./user";

export const getToken = (
    user: string,
    secret: string,
    action: Action,
    unixTimeSecs: number,
): string =>
    createHash("sha256")
        .update(
            [user, secret, action.replace(/^\//, ""), `${unixTimeSecs}`].join(
                ":",
            ),
        )
        .digest("base64")
        .toString();

export const getAuthHeader = (
    user: string,
    secret: string,
    action: Action,
    unixTimeSecs: number,
): string => {
    const token = getToken(user, secret, action, unixTimeSecs);
    return [user, token, `${unixTimeSecs}`].join(":");
};

export const accessAllowed = (userAccess: Permission): boolean => {
    return userAccess === "full" || userAccess === "local";
};

export const splitAuthHeader = (
    authHeader: string | undefined,
): { username: string; token: string; timestamp: number } | null => {
    const result = authHeader === undefined ? [] : authHeader.split(":");

    const [username, token, timestamp] = result;
    if (
        username === undefined ||
        token === undefined ||
        timestamp === undefined
    )
        return null;

    return { username, token, timestamp: Number.parseInt(timestamp, 10) };
};

export const verifyTimestamps = (
    timestampA: number,
    timestampB: number,
): boolean => Math.abs(timestampA - timestampB) < 5 * 60;

const getPermissions = (
    action: Action,
    permissions: Permissions,
): null | Permission => {
    const mapping: Record<Action, null | Permission> = {
        "/user": null,
        "/state": null,
        "/buzzer": permissions.buzzer,
        "/lock": permissions.frontdoor,
        "/unlock": permissions.frontdoor,
        "/unlatch": permissions.unlatch,
        "/doorbell": null,
        "/arrived": permissions["arm/buzzer"],
        "/arm/unlatch": permissions["arm/unlatch"],
        "/arm/buzzer": permissions["arm/buzzer"],
        "/pushnotifications": "full",
    };
    return mapping[action];
};

export const verifyAuth = (
    header: string | undefined,
    configuration: Configuration,
    action: Action,
    now: number = new Date().getTime() / 1000,
): boolean => {
    const skipAuth = configuration.disableAuth ?? false;

    if (header === undefined) {
        return false;
    }

    const headerParts = splitAuthHeader(header);
    if (headerParts === null) {
        return false;
    }

    const { username, token, timestamp } = headerParts;

    if (!skipAuth && !verifyTimestamps(timestamp, now)) {
        return false;
    }

    const user = findUser(username, configuration.users);
    if (user === null) {
        return false;
    }

    if (
        !skipAuth &&
        getToken(user.username, user.secret, action, timestamp) !== token
    ) {
        return false;
    }

    const permission = getPermissions(action, user.permissions);

    if (permission !== null) {
        if (!accessAllowed(permission)) {
            return false;
        }
    }

    console.log(`🧑 Authorized user: ${user.username}`);

    return true;
};
