import { Router } from 'express';
import { checkDatabaseConnection, checkMigrationStatus } from '../controllers/databaseDiagnosticController';

const router = Router();

// Public diagnostic endpoints for debugging
router.get('/connection', checkDatabaseConnection);
router.get('/migrations', checkMigrationStatus);

export default router;