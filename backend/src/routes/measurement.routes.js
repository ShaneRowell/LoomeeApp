const express = require('express');
const router = express.Router();
const measurementController = require('../controllers/measurement.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication
router.post('/', authMiddleware, measurementController.addMeasurements);
router.get('/', authMiddleware, measurementController.getMeasurements);
router.get('/:userId', authMiddleware, measurementController.getMeasurementsByUserId);
router.delete('/', authMiddleware, measurementController.deleteMeasurements);

module.exports = router;