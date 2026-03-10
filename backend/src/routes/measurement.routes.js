const express = require('express');
const router = express.Router();
const measurementController = require('../controllers/measurement.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication — measurements are private user data
router.post('/', authMiddleware, measurementController.addMeasurements);   // Add or update measurements
router.get('/', authMiddleware, measurementController.getMeasurements);     // Get current user's measurements
router.get('/:userId', authMiddleware, measurementController.getMeasurementsByUserId); // Admin: get by user ID
router.delete('/', authMiddleware, measurementController.deleteMeasurements); // Delete current user's measurements

module.exports = router;