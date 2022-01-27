import test from 'ava';
import { getAuthHeader } from './auth';

test('authHeader', (t) => {
  const authHeader = getAuthHeader('max', 'abcdef', 'knock', 4223);
  t.is(authHeader, 'max/W+NY2oWK9s6GACoWmvuj8D2yQ4lIF5BRGblvWGYWpvc=/4223');
});

test('make sure different params create different headers', (t) => {
  const authHeader = getAuthHeader('max', 'abcdef', 'knock', 4223);
  t.not(authHeader, getAuthHeader('max', 'abcdef', 'knock', 123));
  t.not(authHeader, getAuthHeader('not max', 'abcdef', 'knock', 4223));
  t.not(authHeader, getAuthHeader('max', 'other secret', 'knock', 4223));
  t.not(authHeader, getAuthHeader('max', 'abcdef', 'knock twice', 4223));
});
