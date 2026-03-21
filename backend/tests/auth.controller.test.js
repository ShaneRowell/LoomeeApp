process.env.JWT_SECRET = 'test-secret';

jest.mock('../src/models/user.model', () => ({
  findOne: jest.fn(),
  findById: jest.fn(),
}));

const User = require('../src/models/user.model');
const authController = require('../src/controllers/auth.controller');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
};

describe('Auth Controller - Registration Validation', () => {
  test('returns 400 when email is missing', async () => {
    const req = { body: { password: 'pass123', name: 'Test User' } };
    const res = mockRes();
    await authController.register(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide email, password, and name' })
    );
  });

  test('returns 400 when password is missing', async () => {
    const req = { body: { email: 'test@test.com', name: 'Test User' } };
    const res = mockRes();
    await authController.register(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide email, password, and name' })
    );
  });

  test('returns 400 when name is missing', async () => {
    const req = { body: { email: 'test@test.com', password: 'pass123' } };
    const res = mockRes();
    await authController.register(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide email, password, and name' })
    );
  });

  test('returns 400 for an invalid email format', async () => {
    const req = { body: { email: 'not-an-email', password: 'pass123', name: 'Test User' } };
    const res = mockRes();
    await authController.register(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide a valid email address' })
    );
  });

  test('returns 400 when password is shorter than 6 characters', async () => {
    const req = { body: { email: 'test@test.com', password: '123', name: 'Test User' } };
    const res = mockRes();
    await authController.register(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Password must be at least 6 characters long' })
    );
  });
});

describe('Auth Controller - Login Validation', () => {
  test('returns 400 when email is missing', async () => {
    const req = { body: { password: 'pass123' } };
    const res = mockRes();
    await authController.login(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide email and password' })
    );
  });

  test('returns 400 when password is missing', async () => {
    const req = { body: { email: 'test@test.com' } };
    const res = mockRes();
    await authController.login(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Please provide email and password' })
    );
  });

  test('returns 401 when user does not exist', async () => {
    User.findOne.mockResolvedValue(null);
    const req = { body: { email: 'ghost@test.com', password: 'pass123' } };
    const res = mockRes();
    await authController.login(req, res);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Invalid credentials' })
    );
  });
});
