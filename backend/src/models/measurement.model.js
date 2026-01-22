const mongoose = require('mongoose');

const measurementSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  chest: {
    type: Number,
    required: true,
    min: 50,
    max: 200
  },
  waist: {
    type: Number,
    required: true,
    min: 40,
    max: 180
  },
  hips: {
    type: Number,
    required: true,
    min: 50,
    max: 200
  },
  height: {
    type: Number,
    required: true,
    min: 100,
    max: 250
  },
  weight: {
    type: Number,
    required: true,
    min: 30,
    max: 300
  },
  shoulderWidth: {
    type: Number,
    min: 30,
    max: 80
  },
  inseam: {
    type: Number,
    min: 50,
    max: 120
  },
  photoUrl: {
    type: String
  },
  unit: {
    type: String,
    enum: ['cm', 'inches'],
    default: 'cm'
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Measurement', measurementSchema);