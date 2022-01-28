import { allUsers } from '../users';
export type Access = 'full' | 'local' | 'none';

export type User = {
  name: string;
  secret: string;
  buzzerAccess: Access;
  frontdoorAccess: Access;
};

export const findUser = (name: string) =>
  allUsers.find((user) => user.name === name);
