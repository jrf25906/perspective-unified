import { Router } from 'express';

const router = Router();

// Check critical environment variables
router.get('/check-env', (req, res) => {
  const envVars = {
    NODE_ENV: process.env.NODE_ENV || 'not set',
    hasJwtSecret: !!process.env.JWT_SECRET,
    jwtSecretLength: process.env.JWT_SECRET?.length || 0,
    hasRefreshTokenSecret: !!process.env.REFRESH_TOKEN_SECRET,
    refreshTokenSecretLength: process.env.REFRESH_TOKEN_SECRET?.length || 0,
    hasDatabaseUrl: !!process.env.DATABASE_URL,
    timestamp: new Date().toISOString()
  };
  
  // Check if minimum requirements are met
  const isConfigured = 
    envVars.hasJwtSecret && 
    envVars.jwtSecretLength >= 32 &&
    envVars.hasRefreshTokenSecret && 
    envVars.refreshTokenSecretLength >= 32;
  
  res.json({
    ...envVars,
    isProperlyConfigured: isConfigured,
    message: isConfigured 
      ? 'Environment variables are properly configured' 
      : 'Missing or invalid environment variables'
  });
});

export default router;