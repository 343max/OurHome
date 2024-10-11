import { plannedActions } from "./plannedActions";

const getTime = () => new Date().getTime() / 1000;

test("isArmedDoorbellAction - null", () => {
    const { isArmedAction: isArmedDoorbellAction } = plannedActions();
    expect(isArmedDoorbellAction(null)).toBeFalsy();
});

test("isArmedDoorbellAction - past", () => {
    const { isArmedAction: isArmedDoorbellAction } = plannedActions();
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() - 10,
            armedBy: "max",
        }),
    ).toBeFalsy();
});

test("isArmedDoorbellAction - future", () => {
    const { isArmedAction: isArmedDoorbellAction } = plannedActions();
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() + 10,
            armedBy: "max",
        }),
    ).toBeTruthy();
});
