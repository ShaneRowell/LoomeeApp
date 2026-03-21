const jwt = require('jsonwebtoken');
const authMiddleware = require('../src/middleware/auth.middleware');

const TEST_SECRET = 'test-secret-key';

describe('Auth Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    process.env.JWT_SECRET = TEST_SECRET;
    req = { header: jest.fn() };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    next = jest.fn();
  });

  test('returns 401 when no Authorization header is present', () => {
    req.header.mockReturnValue(undefined);
    authMiddleware(req, res, next);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false, message: 'No token provided' })
    );
    expect(next).not.toHaveBeenCalled();
  });

  test('returns 401 when token is malformed', () => {
    req.header.mockReturnValue('Bearer not.a.valid.token');
    authMiddleware(req, res, next);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Invalid token' })
    );
    expect(next).not.toHaveBeenCalled();
  });

  test('returns 401 with expired message when token has expired', () => {
    const expiredToken = jwt.sign({ userId: 'user123' }, TEST_SECRET, { expiresIn: '-1s' });
    req.header.mockReturnValue(`Bearer ${expiredToken}`);
    authMiddleware(req, res, next);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Token has expired, please login again' })
    );
    expect(next).not.toHaveBeenCalled();
  });

  test('calls next() and attaches userId to req for a valid token', () => {
    const validToken = jwt.sign({ userId: 'user123' }, TEST_SECRET, { expiresIn: '1d' });
    req.header.mockReturnValue(`Bearer ${validToken}`);
    authMiddleware(req, res, next);
    expect(next).toHaveBeenCalledTimes(1);
    expect(req.userId).toBe('user123');
    expect(res.status).not.toHaveBeenCalled();
  });

  test('returns 401 when token is signed with a different secret', () => {
    const wrongToken = jwt.sign({ userId: 'user123' }, 'wrong-secret', { expiresIn: '1d' });
    req.header.mockReturnValue(`Bearer ${wrongToken}`);
    authMiddleware(req, res, next);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(next).not.toHaveBeenCalled();
  });
});
