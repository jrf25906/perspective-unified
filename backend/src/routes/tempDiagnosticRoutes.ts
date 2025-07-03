import { Router } from 'express';
import { UserService } from '../services/UserService';
import { UserTransformService } from '../services/UserTransformService';
import { TokenRefreshService } from '../services/TokenRefreshService';
import bcrypt from 'bcryptjs';
import logger from '../utils/logger';

const router = Router();

// Temporary diagnostic endpoint for debugging production issues
router.post('/test-login', async (req, res) => {
  const { email, password } = req.body;
  const diagnostics: any = {
    timestamp: new Date().toISOString(),
    steps: []
  };

  try {
    // Step 1: Check input
    diagnostics.steps.push({
      step: 'input_validation',
      hasEmail: !!email,
      hasPassword: !!password,
      emailLength: email?.length || 0,
      passwordLength: password?.length || 0
    });

    if (!email || !password) {
      return res.status(400).json({
        error: 'Missing email or password',
        diagnostics
      });
    }

    // Step 2: Find user
    let user;
    try {
      user = await UserService.findByEmail(email);
      diagnostics.steps.push({
        step: 'find_user',
        found: !!user,
        userId: user?.id,
        hasPasswordHash: !!user?.password_hash,
        passwordHashLength: user?.password_hash?.length || 0
      });
    } catch (error: any) {
      diagnostics.steps.push({
        step: 'find_user',
        error: error.message,
        errorType: error.constructor.name
      });
      throw error;
    }

    if (!user) {
      return res.status(404).json({
        error: 'User not found',
        diagnostics
      });
    }

    // Step 3: Check password
    if (!user.password_hash) {
      return res.status(400).json({
        error: 'User has no password (Google-only account)',
        diagnostics
      });
    }

    // Step 4: Verify password
    let isValid;
    try {
      isValid = await bcrypt.compare(password, user.password_hash);
      diagnostics.steps.push({
        step: 'password_verification',
        isValid
      });
    } catch (error: any) {
      diagnostics.steps.push({
        step: 'password_verification',
        error: error.message,
        errorType: error.constructor.name
      });
      throw error;
    }

    if (!isValid) {
      return res.status(401).json({
        error: 'Invalid password',
        diagnostics
      });
    }

    // Step 5: Transform user
    let transformedUser;
    try {
      transformedUser = await UserTransformService.transformUserForAPI(user);
      diagnostics.steps.push({
        step: 'transform_user',
        success: !!transformedUser
      });
    } catch (error: any) {
      diagnostics.steps.push({
        step: 'transform_user',
        error: error.message,
        errorType: error.constructor.name,
        stack: error.stack
      });
      throw error;
    }

    // Step 6: Generate tokens
    let tokens;
    try {
      tokens = await TokenRefreshService.generateTokenPair(
        {
          id: user.id,
          email: user.email,
          username: user.username
        },
        {
          userAgent: req.headers['user-agent'],
          ipAddress: req.ip
        }
      );
      diagnostics.steps.push({
        step: 'generate_tokens',
        success: true,
        hasAccessToken: !!tokens.accessToken,
        hasRefreshToken: !!tokens.refreshToken
      });
    } catch (error: any) {
      diagnostics.steps.push({
        step: 'generate_tokens',
        error: error.message,
        errorType: error.constructor.name,
        stack: error.stack
      });
      throw error;
    }

    // Success!
    res.json({
      success: true,
      diagnostics,
      result: {
        user: transformedUser,
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.accessTokenExpiresAt.toISOString()
      }
    });

  } catch (error: any) {
    logger.error('Diagnostic login error:', error);
    res.status(500).json({
      error: error.message,
      errorType: error.constructor.name,
      diagnostics,
      stack: process.env.NODE_ENV !== 'production' ? error.stack : undefined
    });
  }
});

// Test user lookup
router.get('/test-user/:email', async (req, res) => {
  try {
    const user = await UserService.findByEmail(req.params.email);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      found: true,
      userId: user.id,
      email: user.email,
      username: user.username,
      hasPasswordHash: !!user.password_hash,
      passwordHashLength: user.password_hash?.length || 0,
      createdAt: user.created_at,
      isGoogleUser: !!user.google_id
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message,
      errorType: error.constructor.name
    });
  }
});

export default router;