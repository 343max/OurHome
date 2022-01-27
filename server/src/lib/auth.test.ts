import test from 'ava';
import { getAuthHeader } from './auth';

test('authHeader', (t) => {
  const authHeader = getAuthHeader('max', 'abcdef', 'lock', 4223);
  t.is(authHeader, 'max/iMai2Pyi17bnMR8yCmzi7Mwf+iHVioMysuBFjr3/QoQ=/4223');
});

test('make sure different params create different headers', (t) => {
  const authHeader = getAuthHeader('max', 'abcdef', 'lock', 4223).split('/')[1];
  t.not(authHeader, getAuthHeader('max', 'abcdef', 'lock', 123).split('/')[1]);
  t.not(
    authHeader,
    getAuthHeader('not max', 'abcdef', 'lock', 4223).split('/')[1]
  );
  t.not(
    authHeader,
    getAuthHeader('max', 'other secret', 'lock', 4223).split('/')[1]
  );
  t.not(
    authHeader,
    getAuthHeader('max', 'abcdef', 'unlatch', 4223).split('/')[1]
  );
});
