const express = require('express');
const router = express.Router();
const catalogController = require('../controllers/catalog.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes (no authentication)
router.get('/', catalogController.getAllClothing);
router.get('/:id', catalogController.getClothingById);
router.get('/category/:category', catalogController.getClothingByCategory);

// Protected routes (authentication required)
router.post('/', authMiddleware, catalogController.addClothing);
router.put('/:id', authMiddleware, catalogController.updateClothing);
router.delete('/:id', authMiddleware, catalogController.deleteClothing);

module.exports = router;