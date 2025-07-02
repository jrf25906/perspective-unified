import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';
import { validate, AuthValidation } from '../validation';

const router = Router();

// Public routes
router.post('/register', 
  validate({ body: AuthValidation.register }),
  (req, res) => AuthController.register(req, res)
);

router.post('/login',
  validate({ body: AuthValidation.login }),
  (req, res) => AuthController.login(req, res)
);

router.post('/google',
  validate({ body: AuthValidation.googleSignIn }),
  (req, res) => AuthController.googleSignIn(req, res)
);

// Test route without authentication
router.get('/test', (req, res) => {
  res.json({ message: 'Auth routes are working!' });
});

// Protected routes
router.get('/profile', authenticateToken, (req, res) => AuthController.getProfile(req as any, res));
// Add /me alias for iOS compatibility
router.get('/me', authenticateToken, (req, res) => AuthController.getProfile(req as any, res));

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
