const express = require('express');
const router = express.Router();
const sizeRecommendationController = require('../controllers/sizeRecommendation.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication — recommendations are personalized to the user's measurements
router.get('/:clothingId', authMiddleware, sizeRecommendationController.getSizeRecommendation);     // Single item
router.post('/bulk', authMiddleware, sizeRecommendationController.getBulkSizeRecommendations);      // Up to 20 items

module.exports = router;