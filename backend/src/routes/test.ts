import express from 'express';
import { TestController } from '../controllers/testController';
import { SimpleDebugController } from '../controllers/simpleDebugController';
import { DirectAuthController } from '../controllers/directAuthController';

const router = express.Router();

// Test endpoint - no auth required
router.get('/status', TestController.testEndpoint);
router.post('/check-user', SimpleDebugController.checkUser);

// Direct auth endpoints - bypass complex transformation logic
router.post('/direct-login', DirectAuthController.testLogin);
router.post('/direct-register', DirectAuthController.testRegister);

export default router;