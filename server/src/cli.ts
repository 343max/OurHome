import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import type { Action } from "./lib/action";
import { getAuthHeader } from "./lib/auth";
import { configurationJsonSchema, loadConfiguration } from "./lib/config";
import { User, findUser } from "./lib/user";

const port = 4278;

const sendRequest = async (
    method: "GET" | "POST",
    action: Action,
    configPath: string,
    username: string,
): Promise<unknown> => {
    const config = loadConfiguration(configPath);
    const max = findUser(username, config.users);
    if (max === null) throw new Error("user not found");

    const url = `http://localhost:${port}${action}`;
    const response = await fetch(url, {
        method,
        headers: {
            authorization: getAuthHeader(
                max.username,
                max.secret,
                action,
                Math.floor(Date.now() / 1000),
            ),
        },
    });
    const text = await response.text();
    try {
        return await JSON.parse(text);
    } catch (error) {
        console.log(text);
        console.log(error);
        return undefined;
    }
};

const command = z.union([
    z.tuple([z.literal("doorbell"), z.string(), z.string()]),
    z.tuple([z.literal("arrived"), z.string(), z.string()]),
    z.tuple([z.literal("get-state"), z.string(), z.string()]),
    z.tuple([z.literal("generate-json-schema")]),
]);

const main = async (args: z.infer<typeof command>) => {
    switch (args[0]) {
        case "doorbell":
            await sendRequest("POST", "/doorbell", args[1], args[2]);
            break;
        case "arrived":
            await sendRequest("POST", "/arrived", args[1], args[2]);
            break;
        case "get-state":
            console.log(await sendRequest("GET", "/state", args[1], args[2]));
            break;
        case "generate-json-schema":
            console.log(
                JSON.stringify(
                    zodToJsonSchema(
                        configurationJsonSchema,
                        "de.343max.our-home.config",
                    ),
                    null,
                    2,
                ),
            );
            break;
    }
};

main(command.parse(process.argv.slice(2)));
