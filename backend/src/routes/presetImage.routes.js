const express = require('express');
const router = express.Router();
const presetImageController = require('../controllers/presetImage.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../middleware/upload.middleware');

// All routes require authentication
router.post('/', authMiddleware, upload.single('image'), presetImageController.uploadPresetImage);
router.get('/', authMiddleware, presetImageController.getPresetImages);
router.get('/default', authMiddleware, presetImageController.getDefaultPresetImage);
router.delete('/:id', authMiddleware, presetImageController.deletePresetImage);
router.put('/:id/set-default', authMiddleware, presetImageController.setDefaultImage);

module.exports = router;