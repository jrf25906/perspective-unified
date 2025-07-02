import express from 'express';
import { TestController } from '../controllers/testController';
import { SimpleDebugController } from '../controllers/simpleDebugController';

const router = express.Router();

// Test endpoint - no auth required
router.get('/status', TestController.testEndpoint);
router.post('/check-user', SimpleDebugController.checkUser);

export default router;