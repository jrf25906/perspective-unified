import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { UserService } from '../services/UserService';
import logger from '../utils/logger';

export class AuthDebugController {
  /**
   * Debug endpoint to check password hashing
   * POST /api/auth/debug/check-password
   */
  static async checkPassword(req: Request, res: Response) {
    try {
      const { email, password, testHash } = req.body;

      logger.info('Password debug check', {
        email,
        hasPassword: !!password,
        hasTestHash: !!testHash
      });

      // If testHash is provided, just test the hash
      if (testHash && password) {
        const isValid = await bcrypt.compare(password, testHash);
        return res.json({
          testHash,
          password: password.substring(0, 3) + '***',
          isValid,
          hashRounds: bcrypt.getRounds(testHash)
        });
      }

      // Find user by email
      if (email) {
        const user = await UserService.findByEmail(email);
        
        if (!user) {
          return res.json({
            email,
            userFound: false,
            message: 'No user found with this email'
          });
        }

        const debugInfo: any = {
          email,
          userFound: true,
          userId: user.id,
          username: user.username,
          hasPasswordHash: !!user.password_hash,
          passwordHashLength: user.password_hash?.length || 0,
          createdAt: user.created_at,
          updatedAt: user.updated_at
        };

        // If password provided, test it
        if (password && user.password_hash) {
          const isValid = await bcrypt.compare(password, user.password_hash);
          debugInfo.passwordTest = {
            providedPassword: password.substring(0, 3) + '***',
            isValid,
            hashRounds: bcrypt.getRounds(user.password_hash),
            hashPrefix: user.password_hash.substring(0, 10) + '***'
          };

          // Test hash generation
          const testHash = await bcrypt.hash(password, 10);
          debugInfo.testHashGeneration = {
            newHash: testHash.substring(0, 10) + '***',
            wouldMatch: await bcrypt.compare(password, testHash)
          };
        }

        return res.json(debugInfo);
      }

      return res.status(400).json({
        error: 'Please provide email or (password + testHash)'
      });

    } catch (error) {
      logger.error('Password debug error:', error);
      res.status(500).json({
        error: 'Debug check failed',
        message: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  /**
   * List recent registrations for debugging
   * GET /api/auth/debug/recent-users
   */
  static async listRecentUsers(req: Request, res: Response) {
    try {
      const users = await UserService.getRecentUsers(5);
      
      const sanitizedUsers = users.map(user => ({
        id: user.id,
        email: user.email.replace(/^(.{3}).*@/, '$1***@'),
        username: user.username,
        hasPassword: !!user.password_hash,
        hasGoogleId: !!user.google_id,
        createdAt: user.created_at,
        lastActivity: user.last_activity_date
      }));

      res.json({
        users: sanitizedUsers,
        count: sanitizedUsers.length
      });

    } catch (error) {
      logger.error('Recent users debug error:', error);
      res.status(500).json({
        error: 'Failed to fetch recent users',
        message: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}