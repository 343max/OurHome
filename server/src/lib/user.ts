import { configuration } from "../secrets";

import { z } from "zod";

const PermissionSchema = z.enum(["full", "local", "none"]);

const PermissionsSchema = z.object({
    buzzer: PermissionSchema,
    frontdoor: PermissionSchema,
    unlatch: PermissionSchema,
    "arm/buzzer": PermissionSchema,
    "arm/unlatch": PermissionSchema,
});

export const UserSchema = z.object({
    username: z.string(),
    displayName: z.string(),
    secret: z.string(),
    permissions: PermissionsSchema,
});

export type Permission = z.infer<typeof PermissionSchema>;
export type Permissions = z.infer<typeof PermissionsSchema>;
export type User = z.infer<typeof UserSchema>;

export const findUser = (
    username: string,
    users: User[] = configuration.users,
): User | null => users.find((user) => user.username === username) ?? null;

export const dumpInviteLinks = () => {
    const inviteLinks = configuration.users.map(
        ({ username, secret }) =>
            `https://buzzer.343max.com/login?user=${username}&key=${secret}`,
    );

    console.log(inviteLinks.join("\n"));
};
