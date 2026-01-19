const express = require('express');
const router = express.Router();
const fashionRecommendationController = require('../controllers/fashionRecommendation.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public — get outfit recommendations for any clothing item by ID
router.get('/:clothingId', fashionRecommendationController.getRecommendations);

// Protected — personalized recommendations based on the user's measurements
router.get('/personalized/for-you', authMiddleware, fashionRecommendationController.getPersonalizedRecommendations);

// Public — get a complete outfit combination for a given occasion
router.get('/outfit/complete', fashionRecommendationController.getCompleteOutfit);

module.exports = router;