import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';
import { validate, AuthValidation } from '../validation';

const router = Router();

// Public routes
router.post('/register', 
  validate({ body: AuthValidation.register }),
  AuthController.register
);

router.post('/login',
  validate({ body: AuthValidation.login }),
  AuthController.login
);

router.post('/google',
  validate({ body: AuthValidation.googleSignIn }),
  AuthController.googleSignIn
);

// Test route without authentication
router.get('/test', (req, res) => {
  res.json({ message: 'Auth routes are working!' });
});

// Protected routes
router.get('/profile', authenticateToken, AuthController.getProfile);
// Add /me alias for iOS compatibility
router.get('/me', authenticateToken, AuthController.getProfile);

// Token refresh endpoint - commented out until implemented
// router.post('/refresh', 
//   validate({ body: AuthValidation.refreshToken }),
//   AuthController.refreshToken
// );

// Debug endpoints (only in development)
if (process.env.NODE_ENV === 'development' || process.env.ENABLE_DEBUG === 'true') {
  const { AuthDebugController } = require('../controllers/authDebugController');
  router.post('/debug/check-password', AuthDebugController.checkPassword);
  router.get('/debug/recent-users', AuthDebugController.listRecentUsers);
}

export default router; 
