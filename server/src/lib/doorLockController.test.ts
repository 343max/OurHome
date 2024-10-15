import type { Buzzer } from "./buzzer";
import { setupDoorLockController } from "./doorLockController";
import type { Nuki } from "./nuki";
import { setupPlannedActions } from "./plannedActions";

const MockBuzzer: () => ReturnType<Buzzer> & {
    simulateDoorbellPress: () => void;
} = () => {
    let doorbellHandler: (() => Promise<"success" | "failure">) | null = null;
    return {
        pressBuzzer: jest.fn(),
        registerDoorbellHandler: (handler) => {
            doorbellHandler = handler;
        },
        simulateDoorbellPress: async () => {
            await doorbellHandler?.();
        },
    };
};

describe("doorLockController", () => {
    const getTimeMock = jest.fn();
    getTimeMock.mockReturnValue(0);
    const sendPush = jest.fn();

    const mockBuzzer = MockBuzzer();
    const mockNuki: Nuki = {
        lock: jest.fn().mockResolvedValue({ success: true }),
        unlock: jest.fn().mockResolvedValue({ success: true }),
        unlatch: jest.fn().mockResolvedValue({ success: true }),
        getState: jest.fn().mockResolvedValue(null),
    };

    const plannedActions = setupPlannedActions(getTimeMock);

    const doorLockController = setupDoorLockController(
        plannedActions,
        {
            buzzer: mockBuzzer,
            nuki: mockNuki,
            users: [
                {
                    username: "max",
                    displayName: "Max Mustermann",
                    secret: "secret",
                    permissions: {
                        buzzer: "full",
                        frontdoor: "full",
                        unlatch: "full",
                        "arm/buzzer": "full",
                        "arm/unlatch": "full",
                    },
                },
            ],
            buzzerArmTimeout: 1,
            unlatchArmTimeout: 1,
            arrivalTimeout: 1,
        },
        sendPush,
        {
            getDoorbellRingSubscribers: async () => [
                { deviceToken: "abc", username: "ring subscriber" },
            ],
            getUserTokens: async () => [
                { deviceToken: "def", username: "user" },
            ],
            getWhenOtherUserArrivesSubscribers: async () => {
                return [
                    {
                        deviceToken: "ghi",
                        username: "arriving user subscriber",
                    },
                ];
            },
        },
    );

    test("just buzzing shouldn't do anything", () => {
        mockBuzzer.simulateDoorbellPress();
        expect(mockBuzzer.pressBuzzer).not.toHaveBeenCalled();
    });

    test("ringing after arrival should buzz the door", async () => {
        await doorLockController.userArrived("max");
        await mockBuzzer.simulateDoorbellPress();
        expect(mockBuzzer.pressBuzzer).toHaveBeenCalled();
    });
});
