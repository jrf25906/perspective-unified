import express from 'express';
import { TestController } from '../controllers/testController';

const router = express.Router();

// Test endpoint - no auth required
router.get('/status', TestController.testEndpoint);

export default router;