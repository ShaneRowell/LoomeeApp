const mongoose = require('mongoose');

const presetImageSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  imageType: {
    type: String,
    enum: ['front', 'side', 'back', 'custom'],
    default: 'front'
  },
  isDefault: {
    type: Boolean,
    default: false
  },
  uploadedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('PresetImage', presetImageSchema);