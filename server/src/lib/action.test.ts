import { actionForPath } from "./action";

test("actions", () => {
    expect(actionForPath("/pushnotifications/:deviceid")).toBe(
        "/pushnotifications",
    );
});
