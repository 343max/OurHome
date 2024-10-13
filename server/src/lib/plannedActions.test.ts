import { isArmedAction, setupPlannedActions } from "./plannedActions";

const getTime = () => new Date().getTime() / 1000;

describe("isArmedAction", () => {
    test("null", () => {
        expect(isArmedAction(null, getTime)).toBeFalsy();
    });

    test("past", () => {
        expect(
            isArmedAction(
                {
                    type: "buzzer",
                    timeout: getTime() - 10,
                    armedBy: "max",
                },
                getTime,
            ),
        ).toBeFalsy();
    });

    test("future", () => {
        expect(
            isArmedAction(
                {
                    type: "buzzer",
                    timeout: getTime() + 10,
                    armedBy: "max",
                },
                getTime,
            ),
        ).toBeTruthy();
    });
});

describe("plannedActions", () => {
    const getTimeMock = jest.fn();
    const plannedActions = setupPlannedActions(getTimeMock);

    it("should still be armed during the timeout", () => {
        getTimeMock.mockReturnValue(0);
        plannedActions.armForPlannedAction({
            type: "buzzer",
            timeout: 10,
            armedBy: "max",
        });
        getTimeMock.mockReturnValue(5);
        expect(plannedActions.getCurrentPlannedAction()).toEqual({
            type: "buzzer",
            timeout: 10,
            armedBy: "max",
        });
    });

    it("should not be armed after the timeout", () => {
        getTimeMock.mockReturnValue(0);
        plannedActions.armForPlannedAction({
            type: "buzzer",
            timeout: 10,
            armedBy: "max",
        });
        getTimeMock.mockReturnValue(15);
        expect(plannedActions.getCurrentPlannedAction()).toBeNull();
    });
});
