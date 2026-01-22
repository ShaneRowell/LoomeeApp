const mongoose = require('mongoose');

const clothingSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['shirt', 'pants', 'dress', 'jacket', 'skirt', 'shorts', 'sweater', 'suit', 'accessories']
  },
  brand: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  currency: {
    type: String,
    default: 'LKR'
  },
  sizes: [{
    size: {
      type: String,
      enum: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL']
    },
    measurements: {
      chest: Number,
      waist: Number,
      hips: Number,
      length: Number
    },
    stock: {
      type: Number,
      default: 0
    }
  }],
  colors: [{
    name: String,
    hex: String,
    imageUrl: String
  }],
  images: [String],
  model3D: {
    type: String,
    default: null
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'unisex'],
    required: true
  },
  material: {
    type: String
  },
  tags: [String],
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Clothing', clothingSchema);