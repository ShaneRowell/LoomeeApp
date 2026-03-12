const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes — no authentication required
router.post('/register', authController.register);
router.post('/login', authController.login);

// Protected routes — valid JWT required
router.get('/me', authMiddleware, authController.getMe);

module.exports = router;