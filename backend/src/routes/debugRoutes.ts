import { Router } from 'express';
import { debugRegister } from '../controllers/debugAuthController';

const router = Router();

// Debug endpoint to test registration with detailed error info
router.post('/register', debugRegister);

export default router;