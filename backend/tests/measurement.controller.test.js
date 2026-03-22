jest.mock('../src/models/measurement.model', () => ({
  findOne: jest.fn(),
  findOneAndDelete: jest.fn(),
}));

jest.mock('../src/models/user.model', () => ({
  findByIdAndUpdate: jest.fn(),
}));

const Measurement = require('../src/models/measurement.model');
const measurementController = require('../src/controllers/measurement.controller');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
};

describe('Measurement Controller - Add Measurements Validation', () => {
  test('returns 400 when all required fields are missing', async () => {
    const req = { body: {}, userId: 'user123' };
    const res = mockRes();
    await measurementController.addMeasurements(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ success: false })
    );
  });

  test('returns 400 when only some required fields are provided', async () => {
    const req = { body: { chest: 90, waist: 75 }, userId: 'user123' };
    const res = mockRes();
    await measurementController.addMeasurements(req, res);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        message: expect.stringContaining('Missing required fields'),
      })
    );
  });

  test('missing fields message lists the absent field names', async () => {
    const req = { body: { chest: 90 }, userId: 'user123' };
    const res = mockRes();
    await measurementController.addMeasurements(req, res);
    const jsonArg = res.json.mock.calls[0][0];
    expect(jsonArg.message).toContain('waist');
    expect(jsonArg.message).toContain('hips');
    expect(jsonArg.message).toContain('height');
    expect(jsonArg.message).toContain('weight');
  });
});

describe('Measurement Controller - Get Measurements', () => {
  test('returns 404 when no measurements exist for the user', async () => {
    Measurement.findOne.mockReturnValue({
      populate: jest.fn().mockResolvedValue(null),
    });
    const req = { userId: 'user123' };
    const res = mockRes();
    await measurementController.getMeasurements(req, res);
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'No measurements found for this user' })
    );
  });
});

describe('Measurement Controller - Delete Measurements', () => {
  test('returns 404 when no measurements exist to delete', async () => {
    Measurement.findOneAndDelete.mockResolvedValue(null);
    const req = { userId: 'user123' };
    const res = mockRes();
    await measurementController.deleteMeasurements(req, res);
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'No measurements found' })
    );
  });
});
