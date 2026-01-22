const express = require('express');
const router = express.Router();
const sizeRecommendationController = require('../controllers/sizeRecommendation.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication
router.get('/:clothingId', authMiddleware, sizeRecommendationController.getSizeRecommendation);
router.post('/bulk', authMiddleware, sizeRecommendationController.getBulkSizeRecommendations);

module.exports = router;