import type { Buzzer } from "./buzzer";
import type { Nuki } from "./nuki";

export type Configuration = {
    buzzer: Buzzer;
    nuki: Nuki;
    buzzerArmTimeout: number;
    unlatchArmTimeout: number;
    arrivalTimeout: number;
    applePushNotifications: {
        deviceTokenDBPath: string;
        teamId: string;
        signingKeyId: string;
        signingKey: string;
        topic: string;
        production: boolean;
    };
    disableAuth?: boolean;
    httpPort: number;
};
