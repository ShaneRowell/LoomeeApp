const mongoose = require('mongoose');

const tryOnSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  clothingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Clothing',
    required: true
  },
  presetImageId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'PresetImage',
    required: true
  },
  clothingImageUrl: {
    type: String,
    required: true
  },
  resultImageUrl: {
    type: String
  },
  fitAnalysis: {
    overallFit: {
      type: String,
      enum: ['perfect', 'good', 'acceptable', 'poor']
    },
    tightAreas: [String],
    looseAreas: [String],
    recommendations: [String],
    confidence: Number
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending'
  },
  errorMessage: String,
  createdAt: {
    type: Date,
    default: Date.now
  },
  completedAt: Date
});

module.exports = mongoose.model('TryOn', tryOnSchema);