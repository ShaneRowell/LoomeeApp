const jwt = require('jsonwebtoken');

/**
 * Authentication middleware
 * Extracts and verifies the JWT from the Authorization: Bearer <token> header.
 * Attaches decoded userId to req.userId for downstream handlers.
 */
const authMiddleware = (req, res, next) => {
  try {
    // Extract token from "Bearer <token>" format
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ 
        success: false,
        message: 'No token provided' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ 
      success: false,
      message: 'Invalid token' 
    });
  }
};

module.exports = authMiddleware;