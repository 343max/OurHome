import { type User, findUser } from "./user";

test("findUser", () => {
    const fakeUsers: User[] = [
        {
            username: "ringo",
            displayName: "Ringo Start",
            secret: "aaa",
            permissions: {
                frontdoor: "full",
                buzzer: "full",
                unlatch: "full",
                "arm/buzzer": "full",
                "arm/unlatch": "full",
            },
        },
        {
            username: "george",
            displayName: "George Harrison",
            secret: "bbbb",
            permissions: {
                frontdoor: "full",
                buzzer: "full",
                unlatch: "full",
                "arm/buzzer": "full",
                "arm/unlatch": "full",
            },
        },
        {
            username: "john",
            displayName: "John Lennon",
            secret: "dead",
            permissions: {
                frontdoor: "full",
                buzzer: "full",
                unlatch: "full",
                "arm/buzzer": "full",
                "arm/unlatch": "full",
            },
        },
        {
            username: "paul",
            displayName: "Paul McCartney",
            secret: "deaf",
            permissions: {
                frontdoor: "full",
                buzzer: "full",
                unlatch: "full",
                "arm/buzzer": "full",
                "arm/unlatch": "full",
            },
        },
    ];

    // biome-ignore lint/style/noNonNullAssertion: test
    const user = findUser("john", fakeUsers)!;
    expect(user.username).toBe("john");

    expect(findUser("nobody", fakeUsers)).toBeNull();
});
