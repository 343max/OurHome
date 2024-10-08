import { APNTokenDBController } from "./APNTokenDb";

test("pushNotifications", async () => {
    const { registerDevice, removeDevice, getDoorbellRingSubscribers } =
        await APNTokenDBController(":memory:");
    await registerDevice("user", "token", ["doorbellRing"]);
    expect(await getDoorbellRingSubscribers()).toEqual([
        {
            deviceToken: "token",
            username: "user",
        },
    ]);
    removeDevice("token");
    expect(await getDoorbellRingSubscribers()).toEqual([]);
});

test("pushNotifications - register twice", async () => {
    const { registerDevice, getUserTokens } =
        await APNTokenDBController(":memory:");
    await registerDevice("user", "token1", ["doorbellRing"]);
    await registerDevice("user", "token1", [
        "doorbellRing",
        "whenOtherUserArrives",
    ]);
    expect(await getUserTokens("user")).toEqual([
        {
            deviceToken: "token1",
            username: "user",
        },
    ]);
});

test("pushNotifications - other user arrives", async () => {
    const { registerDevice, getWhenOtherUserArrivesSubscribers } =
        await APNTokenDBController(":memory:");
    await registerDevice("alice", "token1", ["whenOtherUserArrives"]);
    await registerDevice("bob", "token2", ["whenOtherUserArrives"]);
    expect(await getWhenOtherUserArrivesSubscribers("bob")).toEqual([
        {
            deviceToken: "token1",
            username: "alice",
        },
    ]);
});

test("pushNotifications - already prepared", async () => {
    const { prepare } = await APNTokenDBController(":memory:");
    await prepare();
    expect(true).toBeTruthy();
});
