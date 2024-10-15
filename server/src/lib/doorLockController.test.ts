import type { Buzzer } from "./buzzer";
import { setupDoorLockController } from "./doorLockController";
import type { Nuki } from "./nuki";
import { setupPlannedActions } from "./plannedActions";

describe("doorLockController", () => {
    const setup = () => {
        const getTimeMock = jest.fn();
        getTimeMock.mockReturnValue(0);

        const handleAnonymousDoorbellPress = jest.fn();
        const handleUnlatchingDoorBecauseOfRing = jest.fn();
        const handleUserArrived = jest.fn();

        let mockBuzzerDoorbellHandler:
            | (() => Promise<"success" | "failure">)
            | null = null;

        const simulateDoorbellPress = async () => {
            await mockBuzzerDoorbellHandler?.();
        };

        const mockBuzzer: ReturnType<Buzzer> = {
            pressBuzzer: jest.fn(),
            registerDoorbellHandler: (handler) => {
                mockBuzzerDoorbellHandler = handler;
            },
        };

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
            {
                handleAnonymousDoorbellPress,
                handleUnlatchingDoorBecauseOfRing,
                handleUserArrived,
            },
        );
        return {
            getTimeMock,
            mockBuzzer,
            mockNuki,
            plannedActions,
            doorLockController,
            simulateDoorbellPress,
            handleAnonymousDoorbellPress,
            handleUnlatchingDoorBecauseOfRing,
            handleUserArrived,
        };
    };

    test("just buzzing shouldn't do anything", async () => {
        const {
            mockBuzzer,
            simulateDoorbellPress,
            handleAnonymousDoorbellPress,
            handleUnlatchingDoorBecauseOfRing,
            handleUserArrived,
        } = setup();
        await simulateDoorbellPress();
        expect(mockBuzzer.pressBuzzer).not.toHaveBeenCalled();
        expect(handleAnonymousDoorbellPress).toHaveBeenCalled();
        expect(handleUnlatchingDoorBecauseOfRing).not.toHaveBeenCalled();
        expect(handleUserArrived).not.toHaveBeenCalled();
    });

    test("user arrived - should notify others", async () => {
        const {
            doorLockController,
            mockBuzzer,
            handleAnonymousDoorbellPress,
            handleUnlatchingDoorBecauseOfRing,
            handleUserArrived,
        } = setup();
        await doorLockController.userArrived("max");
        expect(mockBuzzer.pressBuzzer).not.toHaveBeenCalled();
        expect(handleAnonymousDoorbellPress).not.toHaveBeenCalled();
        expect(handleUnlatchingDoorBecauseOfRing).not.toHaveBeenCalled();
        expect(handleUserArrived).toHaveBeenCalled();
    });

    test("ringing after arrival should buzz the door", async () => {
        const {
            doorLockController,
            mockBuzzer,
            simulateDoorbellPress,
            handleAnonymousDoorbellPress,
            handleUnlatchingDoorBecauseOfRing,
            handleUserArrived,
        } = setup();
        await doorLockController.userArrived("max");
        await simulateDoorbellPress();
        expect(mockBuzzer.pressBuzzer).toHaveBeenCalled();
        expect(handleAnonymousDoorbellPress).not.toHaveBeenCalled();
        expect(handleUnlatchingDoorBecauseOfRing).toHaveBeenCalled();
        expect(handleUserArrived).toHaveBeenCalled();
    });
});
