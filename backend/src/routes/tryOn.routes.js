const express = require('express');
const router = express.Router();
const tryOnController = require('../controllers/tryOn.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication — try-on sessions are private to each user
router.post('/', authMiddleware, tryOnController.createTryOn);          // Start a new try-on
router.get('/', authMiddleware, tryOnController.getUserTryOns);          // List user's try-on history
router.get('/:id', authMiddleware, tryOnController.getTryOnById);        // Get single result
router.delete('/:id', authMiddleware, tryOnController.deleteTryOn);      // Remove a session

module.exports = router;