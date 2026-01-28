const PresetImage = require('../models/presetImage.model');
const fs = require('fs');
const path = require('path');

// Upload preset image
exports.uploadPresetImage = async (req, res) => {
  try {
    const userId = req.userId;
    const { imageType, isDefault } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload an image file'
      });
    }

    // If this is set as default, unset other defaults
    if (isDefault === 'true' || isDefault === true) {
      await PresetImage.updateMany(
        { userId },
        { isDefault: false }
      );
    }

    // Create preset image record
    const presetImage = new PresetImage({
      userId,
      imageUrl: `/uploads/${req.file.filename}`,
      imageType: imageType || 'front',
      isDefault: isDefault === 'true' || isDefault === true
    });

    await presetImage.save();

    res.status(201).json({
      success: true,
      message: 'Preset image uploaded successfully',
      image: presetImage
    });
  } catch (error) {
    console.error('Upload preset image error:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading preset image',
      error: error.message
    });
  }
};

// Get all preset images for user
exports.getPresetImages = async (req, res) => {
  try {
    const userId = req.userId;

    const images = await PresetImage.find({ userId }).sort({ uploadedAt: -1 });

    res.json({
      success: true,
      count: images.length,
      images
    });
  } catch (error) {
    console.error('Get preset images error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching preset images',
      error: error.message
    });
  }
};

// Get default preset image
exports.getDefaultPresetImage = async (req, res) => {
  try {
    const userId = req.userId;

    const image = await PresetImage.findOne({ userId, isDefault: true });

    if (!image) {
      return res.status(404).json({
        success: false,
        message: 'No default preset image found'
      });
    }

    res.json({
      success: true,
      image
    });
  } catch (error) {
    console.error('Get default preset image error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching default preset image',
      error: error.message
    });
  }
};

// Delete preset image
exports.deletePresetImage = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    const image = await PresetImage.findOne({ _id: id, userId });

    if (!image) {
      return res.status(404).json({
        success: false,
        message: 'Preset image not found'
      });
    }

    // Delete file from disk
    const filePath = path.join(__dirname, '../../', image.imageUrl);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await PresetImage.findByIdAndDelete(id);

    res.json({
      success: true,
      message: 'Preset image deleted successfully'
    });
  } catch (error) {
    console.error('Delete preset image error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting preset image',
      error: error.message
    });
  }
};

// Set image as default
exports.setDefaultImage = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    // Unset all defaults
    await PresetImage.updateMany({ userId }, { isDefault: false });

    // Set new default
    const image = await PresetImage.findOneAndUpdate(
      { _id: id, userId },
      { isDefault: true },
      { new: true }
    );

    if (!image) {
      return res.status(404).json({
        success: false,
        message: 'Preset image not found'
      });
    }

    res.json({
      success: true,
      message: 'Default image updated successfully',
      image
    });
  } catch (error) {
    console.error('Set default image error:', error);
    res.status(500).json({
      success: false,
      message: 'Error setting default image',
      error: error.message
    });
  }
};