import { createHash } from 'crypto';

export const getAuthHeader = (
  user: string,
  secret: string,
  action: string,
  unixTimeSecs: number
): string => {
  const token = createHash('sha256')
    .update([user, secret, action, `${unixTimeSecs}`].join('/'))
    .digest('base64');
  return [user, token, unixTimeSecs].join('/');
};
