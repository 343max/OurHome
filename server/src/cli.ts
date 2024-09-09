import { z } from "zod";
import type { Action } from "./lib/action";
import { getAuthHeader } from "./lib/auth";
import { findUser } from "./lib/user";

const port = 4278;

const sendRequest = async (
    method: "GET" | "POST",
    action: Action,
): Promise<unknown> => {
    const max = findUser("max");
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

const command = z.enum(["doorbell", "arrived", "get-state"]);
type Command = z.infer<typeof command>;

const main = async (command: Command) => {
    switch (command) {
        case "doorbell":
            await sendRequest("POST", "/doorbell");
            break;
        case "arrived":
            await sendRequest("POST", "/arrived");
            break;
        case "get-state":
            console.log(await sendRequest("GET", "/state"));
            break;
    }
};

main(command.parse(process.argv[2]));
