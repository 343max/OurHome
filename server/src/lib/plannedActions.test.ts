import { plannedActions } from "./plannedActions";

const getTime = () => new Date().getTime() / 1000;

test("isArmedDoorbellAction - null", () => {
    const { isArmedDoorbellAction } = plannedActions();
    expect(isArmedDoorbellAction(null)).toBeFalsy();
});

test("isArmedDoorbellAction - past", () => {
    const { isArmedDoorbellAction } = plannedActions();
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() - 10,
            armedBy: "max",
        }),
    ).toBeFalsy();
});

test("isArmedDoorbellAction - future", () => {
    const { isArmedDoorbellAction } = plannedActions();
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() + 10,
            armedBy: "max",
        }),
    ).toBeTruthy();
});
