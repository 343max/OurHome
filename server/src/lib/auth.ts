import { Action } from './action';
import { createHash } from 'crypto';

const getToken = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string =>
  createHash('sha256')
    .update([user, secret, action, `${unixTimeSecs}`].join('/'))
    .digest('base64');

export const getAuthHeader = (
  user: string,
  secret: string,
  action: Action,
  unixTimeSecs: number
): string => {
  const token = getToken(user, secret, action, unixTimeSecs);
  return [user, token, `${unixTimeSecs}`].join('/');
};
