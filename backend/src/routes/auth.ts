import express from 'express';
import { AuthController } from '../controllers/authController';
import { AuthDebugController } from '../controllers/authDebugController';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();

/**
 * Authentication Routes
 * 
 * Enhanced with refresh token support and comprehensive session management
 */

// Registration endpoint
router.post('/register', AuthController.register);

// Login endpoint
router.post('/login', AuthController.login);

// Google Sign-In endpoint
router.post('/google', AuthController.googleSignIn);

// Refresh token endpoint
router.post('/refresh', AuthController.refreshToken);

// Logout endpoint (with refresh token revocation)
router.post('/logout', AuthController.logout);

// Logout from all devices endpoint
router.post('/logout-all', authenticateToken, AuthController.logoutAll);

// Get current user profile
router.get('/me', authenticateToken, AuthController.getProfile);

// Debug endpoints (only in development)
if (process.env.NODE_ENV === 'development') {
  router.post('/debug/check-password', AuthDebugController.checkPassword);
  router.get('/debug/recent-users', AuthDebugController.listRecentUsers);
}

export default router; 