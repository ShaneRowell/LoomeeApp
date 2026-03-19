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
  // Status lifecycle: pending → processing → completed | failed
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending'
  },
  // Live progress tracking — updated by the background AI pipeline so the
  // client can show a real progress bar instead of a wall-clock simulation.
  progress: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  currentStage: {
    type: String,
    default: 'starting'
  },
  errorMessage: String,  // Populated only when status is 'failed'
  createdAt: {
    type: Date,
    default: Date.now
  },
  completedAt: Date
});

module.exports = mongoose.model('TryOn', tryOnSchema);