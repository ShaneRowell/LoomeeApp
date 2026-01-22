const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'Server is running!',
    timestamp: new Date().toISOString()
  });
});

// Auth routes
const authRoutes = require('./src/routes/auth.routes');
app.use('/api/auth', authRoutes);

// Measurement routes
const measurementRoutes = require('./src/routes/measurement.routes');
app.use('/api/measurements', measurementRoutes);

// Catalog routes
const catalogRoutes = require('./src/routes/catalog.routes');
app.use('/api/catalog', catalogRoutes);

// Size recommendation routes
const sizeRecommendationRoutes = require('./src/routes/sizeRecommendation.routes');
app.use('/api/size-recommendation', sizeRecommendationRoutes);

// Database connection
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('❌ MONGODB_URI is not defined in .env file');
  process.exit(1);
}

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('✅ Connected to MongoDB');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`\n📍 Available endpoints:`);
      console.log(`   GET  http://localhost:${PORT}/api/health`);
      console.log(`   POST http://localhost:${PORT}/api/auth/register`);
      console.log(`   POST http://localhost:${PORT}/api/auth/login`);
      console.log(`   GET  http://localhost:${PORT}/api/auth/me`);
      console.log(`   POST http://localhost:${PORT}/api/measurements`);
      console.log(`   GET  http://localhost:${PORT}/api/measurements`);
      console.log(`   GET  http://localhost:${PORT}/api/catalog`);
      console.log(`   POST http://localhost:${PORT}/api/catalog`);
      console.log(`   GET  http://localhost:${PORT}/api/size-recommendation/:clothingId`);
      console.log(`   POST http://localhost:${PORT}/api/size-recommendation/bulk`);
    });
  })
  .catch((error) => {
    console.error('❌ MongoDB connection error:', error.message);
  });

module.exports = app;
