import { isArmedDoorbellAction } from "./arrivedRecently";

const getTime = () => new Date().getTime() / 1000;

test("isArmedDoorbellAction - null", () => {
    expect(isArmedDoorbellAction(null)).toBeFalsy();
});

test("isArmedDoorbellAction - past", () => {
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() - 10,
            armedBy: "max",
        }),
    ).toBeFalsy();
});

test("isArmedDoorbellAction - future", () => {
    expect(
        isArmedDoorbellAction({
            type: "buzzer",
            timeout: getTime() + 10,
            armedBy: "max",
        }),
    ).toBeTruthy();
});
