const express = require('express');
const router = express.Router();
const tryOnController = require('../controllers/tryOn.controller');
const authMiddleware = require('../middleware/auth.middleware');

// All routes require authentication
router.post('/', authMiddleware, tryOnController.createTryOn);
router.get('/', authMiddleware, tryOnController.getUserTryOns);
router.get('/:id', authMiddleware, tryOnController.getTryOnById);
router.delete('/:id', authMiddleware, tryOnController.deleteTryOn);

module.exports = router;