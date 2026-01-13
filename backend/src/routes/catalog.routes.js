const express = require('express');
const router = express.Router();
const catalogController = require('../controllers/catalog.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Public routes — browsing catalog requires no authentication
router.get('/', catalogController.getAllClothing);
router.get('/category/:category', catalogController.getClothingByCategory);
router.get('/:id', catalogController.getClothingById);

// Protected routes — only authenticated admins may modify the catalog
router.post('/', authMiddleware, catalogController.addClothing);
router.put('/:id', authMiddleware, catalogController.updateClothing);
router.delete('/:id', authMiddleware, catalogController.deleteClothing);

module.exports = router;