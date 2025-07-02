import { Request, Response } from 'express';
import logger from '../utils/logger';
import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import { generateToken, AuthenticatedRequest } from '../middleware/auth';
import { CreateUserRequest, LoginRequest, User } from '../models/User';
import { UserService } from '../services/UserService';
import { UserTransformService } from '../services/UserTransformService';
import { TokenRefreshService, DeviceInfo } from '../services/TokenRefreshService';
import { ActivityTrackingService } from '../services/ActivityTrackingService';

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Enhanced Authentication Controller
 * 
 * Integrates with:
 * - TokenRefreshService for secure token rotation
 * - ActivityTrackingService for user activity logging
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles authentication HTTP operations
 * - OCP: Extensible for new authentication methods
 * - DIP: Depends on service abstractions
 */
export class AuthController {
  /**
   * Extract device info from request
   */
  private static extractDeviceInfo(req: Request): DeviceInfo {
    return {
      deviceId: req.headers['x-device-id'] as string,
      deviceName: req.headers['x-device-name'] as string,
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip || req.connection.remoteAddress
    };
  }

  static async register(req: Request, res: Response) {
    try {
      const { email, username, password, first_name, last_name }: CreateUserRequest = req.body;

      // Validate input
      if (!email || !username || !password) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Email, username, and password are required'
          }
        });
      }

      // Check if user already exists
      const existingUser = await UserService.findByEmailOrUsername(email, username);
      if (existingUser) {
        return res.status(409).json({
          error: {
            code: 'USER_EXISTS',
            message: 'User with this email or username already exists'
          }
        });
      }

      // Hash password
      const saltRounds = 12;
      const password_hash = await bcrypt.hash(password, saltRounds);

      // Create user
      logger.info('Creating user with data:', { email, username, first_name, last_name });
      
      const newUser = await UserService.create({
        email,
        username,
        password_hash,
        first_name,
        last_name
      });
      
      logger.info('User created successfully:', { id: newUser.id, email: newUser.email });

      // Generate token pair using TokenRefreshService
      const deviceInfo = this.extractDeviceInfo(req);
      const tokenPair = await TokenRefreshService.generateTokenPair(
        {
          id: newUser.id,
          email: newUser.email,
          username: newUser.username
        },
        deviceInfo
      );

      // Transform user for API response
      const transformedUser = UserTransformService.transformUserForAPI(newUser);
      if (!transformedUser) {
        throw new Error('Failed to transform user data');
      }

      // Track registration activity
      await ActivityTrackingService.trackActivity({
        userId: newUser.id,
        type: 'profile_updated' as any,
        title: 'Account Created',
        description: 'Welcome to Perspective! Your account has been created successfully.',
        category: 'profile' as any,
        visibility: 'private' as any,
        xpEarned: 50 // Welcome bonus
      });

      res.status(201).json({
        user: transformedUser,
        token: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        expiresAt: tokenPair.accessTokenExpiresAt.toISOString()
      });

    } catch (error) {
      logger.error('Registration error:', error);
      logger.error('Error details:', {
        message: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
        name: error instanceof Error ? error.name : undefined
      });
      
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create user',
          details: process.env.NODE_ENV === 'development' ? (error instanceof Error ? error.message : 'Unknown error') : undefined
        }
      });
    }
  }

  static async googleSignIn(req: Request, res: Response) {
    try {
      const { idToken } = req.body;

      if (!idToken) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Google ID token is required'
          }
        });
      }

      // Verify the Google ID token
      let ticket;
      try {
        ticket = await googleClient.verifyIdToken({
          idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
      } catch (error) {
        logger.error('Google token verification failed:', error);
        return res.status(401).json({
          error: {
            code: 'INVALID_TOKEN',
            message: 'Invalid Google ID token'
          }
        });
      }

      const payload = ticket.getPayload();
      if (!payload || !payload.email) {
        return res.status(401).json({
          error: {
            code: 'INVALID_TOKEN',
            message: 'Invalid token payload'
          }
        });
      }

      const { email, name, given_name, family_name, picture } = payload;
      let isNewUser = false;

      // Check if user exists
      let user = await UserService.findByEmail(email);

      if (!user) {
        // Create new user with Google info
        const username = email.split('@')[0]; // Use email prefix as username
        
        // Check if username already exists and make it unique if needed
        let finalUsername = username;
        let counter = 1;
        while (await UserService.findByUsername(finalUsername)) {
          finalUsername = `${username}${counter}`;
          counter++;
        }

        user = await UserService.create({
          email,
          username: finalUsername,
          password_hash: null, // Null for Google users instead of empty string
          first_name: given_name || name?.split(' ')[0] || null,
          last_name: family_name || name?.split(' ').slice(1).join(' ') || null,
          google_id: payload.sub,
          avatar_url: picture || null,
          email_verified: payload.email_verified || false
        });
        isNewUser = true;
      } else {
        // Update existing user with Google info if not already set
        if (!user.google_id) {
          await UserService.updateGoogleInfo(user.id, {
            google_id: payload.sub,
            avatar_url: picture || user.avatar_url,
            email_verified: payload.email_verified || user.email_verified
          });
        }
        
        // Update last activity
        await UserService.updateLastActivity(user.id);
      }

      // Generate token pair
      const deviceInfo = this.extractDeviceInfo(req);
      const tokenPair = await TokenRefreshService.generateTokenPair(
        {
          id: user.id,
          email: user.email,
          username: user.username
        },
        deviceInfo
      );

      // Transform user for API response
      const transformedUser = UserTransformService.transformUserForAPI(user);
      if (!transformedUser) {
        throw new Error('Failed to transform user data');
      }

      // Track activity
      if (isNewUser) {
        await ActivityTrackingService.trackActivity({
          userId: user.id,
          type: 'profile_updated' as any,
          title: 'Account Created via Google',
          description: 'Welcome to Perspective! Your account has been created using Google Sign-In.',
          category: 'profile' as any,
          visibility: 'private' as any,
          xpEarned: 50
        });
      }

      res.json({
        user: transformedUser,
        token: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        expiresAt: tokenPair.accessTokenExpiresAt.toISOString()
      });

    } catch (error) {
      logger.error('Google sign-in error:', error);
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to authenticate with Google'
        }
      });
    }
  }

  static async login(req: Request, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    const startTime = Date.now();
    
    try {
      const { email, password }: LoginRequest = req.body;

      logger.info('Login attempt started', {
        correlationId,
        email: email ? email.replace(/^(.{3}).*@/, '$1***@') : 'not provided',
        timestamp: new Date().toISOString()
      });

      // Validate input
      if (!email || !password) {
        logger.warn('Login validation failed: missing credentials', {
          correlationId,
          hasEmail: !!email,
          hasPassword: !!password
        });
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Email and password are required'
          }
        });
      }

      // Find user
      const user = await UserService.findByEmail(email);
      
      if (!user) {
        logger.warn('Login failed: user not found', {
          correlationId,
          email: email.replace(/^(.{3}).*@/, '$1***@'),
          duration: Date.now() - startTime
        });
        return res.status(401).json({
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      }

      // Check if user has a password (not a Google-only user)
      if (!user.password_hash) {
        logger.warn('Login failed: user has no password (Google-only account)', {
          correlationId,
          userId: user.id,
          duration: Date.now() - startTime
        });
        return res.status(401).json({
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, user.password_hash);
      
      if (!isValidPassword) {
        logger.warn('Login failed: invalid password', {
          correlationId,
          userId: user.id,
          duration: Date.now() - startTime
        });
        return res.status(401).json({
          error: {
            code: 'INVALID_CREDENTIALS',
            message: 'Invalid email or password'
          }
        });
      }
      
      // Update last activity
      await UserService.updateLastActivity(user.id);

      // Generate token pair
      const deviceInfo = this.extractDeviceInfo(req);
      const tokenPair = await TokenRefreshService.generateTokenPair(
        {
          id: user.id,
          email: user.email,
          username: user.username
        },
        deviceInfo
      );

      // Transform user for API response
      const transformedUser = UserTransformService.transformUserForAPI(user);
      if (!transformedUser) {
        throw new Error('Failed to transform user data');
      }

      logger.info('Login successful', {
        correlationId,
        userId: user.id,
        username: user.username,
        duration: Date.now() - startTime
      });

      res.json({
        user: transformedUser,
        token: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        expiresAt: tokenPair.accessTokenExpiresAt.toISOString()
      });

    } catch (error) {
      logger.error('Login error', {
        correlationId,
        error: error instanceof Error ? {
          message: error.message,
          stack: error.stack,
          name: error.name
        } : error,
        duration: Date.now() - startTime
      });
      
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to authenticate user'
        }
      });
    }
  }

  /**
   * Refresh access token using refresh token
   * POST /auth/refresh
   */
  static async refreshToken(req: Request, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Refresh token is required'
          }
        });
      }

      logger.info('Token refresh requested', { correlationId });

      // Refresh token using TokenRefreshService
      const deviceInfo = this.extractDeviceInfo(req);
      const newTokenPair = await TokenRefreshService.refreshAccessToken(refreshToken, deviceInfo);

      logger.info('Token refresh successful', { correlationId });

      res.json({
        token: newTokenPair.accessToken,
        refreshToken: newTokenPair.refreshToken,
        expiresAt: newTokenPair.accessTokenExpiresAt.toISOString()
      });

    } catch (error) {
      logger.error('Token refresh failed', {
        correlationId,
        error: error instanceof Error ? error.message : 'Unknown error'
      });

      const errorMessage = error instanceof Error ? error.message : 'Token refresh failed';
      let statusCode = 500;
      let errorCode = 'INTERNAL_ERROR';

      if (errorMessage.includes('Invalid refresh token') || 
          errorMessage.includes('not found')) {
        statusCode = 401;
        errorCode = 'INVALID_REFRESH_TOKEN';
      } else if (errorMessage.includes('expired')) {
        statusCode = 401;
        errorCode = 'REFRESH_TOKEN_EXPIRED';
      } else if (errorMessage.includes('revoked')) {
        statusCode = 401;
        errorCode = 'REFRESH_TOKEN_REVOKED';
      }

      res.status(statusCode).json({
        error: {
          code: errorCode,
          message: errorMessage
        }
      });
    }
  }

  /**
   * Logout user and revoke refresh token
   * POST /auth/logout
   */
  static async logout(req: AuthenticatedRequest, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    
    try {
      const { refreshToken } = req.body;

      if (refreshToken) {
        // Extract JTI from refresh token to revoke it
        try {
          const jwt = require('jsonwebtoken');
          const decoded = jwt.decode(refreshToken) as any;
          if (decoded?.jti) {
            await TokenRefreshService.revokeRefreshToken(decoded.jti, 'logout');
          }
        } catch (error) {
          logger.warn('Failed to revoke refresh token during logout', { correlationId, error });
        }
      }

      logger.info('User logged out', {
        correlationId,
        userId: req.user?.id
      });

      res.json({
        success: true,
        message: 'Logged out successfully'
      });

    } catch (error) {
      logger.error('Logout error', { correlationId, error });
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to logout'
        }
      });
    }
  }

  /**
   * Logout from all devices
   * POST /auth/logout-all
   */
  static async logoutAll(req: AuthenticatedRequest, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    
    try {
      if (!req.user) {
        return res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'User not authenticated'
          }
        });
      }

      // Revoke all refresh tokens for the user
      await TokenRefreshService.revokeAllUserTokens(req.user.id, 'logout_all');

      logger.info('User logged out from all devices', {
        correlationId,
        userId: req.user.id
      });

      res.json({
        success: true,
        message: 'Logged out from all devices successfully'
      });

    } catch (error) {
      logger.error('Logout all error', { correlationId, error });
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to logout from all devices'
        }
      });
    }
  }

  static async getProfile(req: AuthenticatedRequest, res: Response) {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'User not authenticated'
          }
        });
      }

      const user = await UserService.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found'
          }
        });
      }

      // Transform user for API response
      const transformedUser = UserTransformService.transformUserForAPI(user);
      if (!transformedUser) {
        throw new Error('Failed to transform user data');
      }

      res.json(transformedUser);

    } catch (error) {
      logger.error('Get profile error:', error);
      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to get user profile'
        }
      });
    }
  }
} 