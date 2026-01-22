const Measurement = require('../models/measurement.model');
const User = require('../models/user.model');

// Add or update measurements
exports.addMeasurements = async (req, res) => {
  try {
    const { chest, waist, hips, height, weight, shoulderWidth, inseam, unit } = req.body;
    const userId = req.userId;

    // Validate required fields
    if (!chest || !waist || !hips || !height || !weight) {
      return res.status(400).json({
        success: false,
        message: 'Please provide chest, waist, hips, height, and weight'
      });
    }

    // Check if measurements already exist
    let measurement = await Measurement.findOne({ userId });

    if (measurement) {
      // Update existing measurements
      measurement.chest = chest;
      measurement.waist = waist;
      measurement.hips = hips;
      measurement.height = height;
      measurement.weight = weight;
      measurement.shoulderWidth = shoulderWidth;
      measurement.inseam = inseam;
      measurement.unit = unit || 'cm';
      measurement.lastUpdated = Date.now();
      
      await measurement.save();

      return res.json({
        success: true,
        message: 'Measurements updated successfully',
        measurement
      });
    }

    // Create new measurements
    measurement = new Measurement({
      userId,
      chest,
      waist,
      hips,
      height,
      weight,
      shoulderWidth,
      inseam,
      unit: unit || 'cm'
    });

    await measurement.save();

    // Update user model with measurements
    await User.findByIdAndUpdate(userId, {
      bodyMeasurements: {
        chest,
        waist,
        hips,
        height,
        weight
      }
    });

    res.status(201).json({
      success: true,
      message: 'Measurements added successfully',
      measurement
    });
  } catch (error) {
    console.error('Add measurements error:', error);
    res.status(500).json({
      success: false,
      message: 'Error adding measurements',
      error: error.message
    });
  }
};

// Get measurements for current user
exports.getMeasurements = async (req, res) => {
  try {
    const userId = req.userId;

    const measurement = await Measurement.findOne({ userId }).populate('userId', 'name email');

    if (!measurement) {
      return res.status(404).json({
        success: false,
        message: 'No measurements found for this user'
      });
    }

    res.json({
      success: true,
      measurement
    });
  } catch (error) {
    console.error('Get measurements error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching measurements',
      error: error.message
    });
  }
};

// Get measurements by user ID (for admins or specific use)
exports.getMeasurementsByUserId = async (req, res) => {
  try {
    const { userId } = req.params;

    const measurement = await Measurement.findOne({ userId }).populate('userId', 'name email');

    if (!measurement) {
      return res.status(404).json({
        success: false,
        message: 'No measurements found for this user'
      });
    }

    res.json({
      success: true,
      measurement
    });
  } catch (error) {
    console.error('Get measurements by userId error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching measurements',
      error: error.message
    });
  }
};

// Delete measurements
exports.deleteMeasurements = async (req, res) => {
  try {
    const userId = req.userId;

    const measurement = await Measurement.findOneAndDelete({ userId });

    if (!measurement) {
      return res.status(404).json({
        success: false,
        message: 'No measurements found'
      });
    }

    res.json({
      success: true,
      message: 'Measurements deleted successfully'
    });
  } catch (error) {
    console.error('Delete measurements error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting measurements',
      error: error.message
    });
  }
};