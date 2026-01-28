const express = require('express');
const router = express.Router();
const fashionRecommendationController = require('../controllers/fashionRecommendation.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Get recommendations for specific clothing item
router.get('/:clothingId', fashionRecommendationController.getRecommendations);

// Get personalized recommendations (requires auth)
router.get('/personalized/for-you', authMiddleware, fashionRecommendationController.getPersonalizedRecommendations);

// Get complete outfit recommendations
router.get('/outfit/complete', fashionRecommendationController.getCompleteOutfit);

module.exports = router;