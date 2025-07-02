import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import db from '../db';
import { UserService } from '../services/UserService';

export class TestController {
  static async testEndpoint(req: Request, res: Response) {
    try {
      // Test database connection
      const dbTest = await db.raw('SELECT 1+1 as result');
      
      // Test bcrypt
      const testPassword = 'TestPassword123!';
      const hash = await bcrypt.hash(testPassword, 10);
      const isValid = await bcrypt.compare(testPassword, hash);
      
      // Get user count
      const userCount = await db('users').count('* as count').first();
      
      // Check if specific user exists
      const { email } = req.query;
      let userInfo = null;
      if (email && typeof email === 'string') {
        const user = await UserService.findByEmail(email);
        if (user) {
          userInfo = {
            found: true,
            id: user.id,
            email: user.email,
            hasPassword: !!user.password_hash,
            passwordHashLength: user.password_hash?.length || 0,
            createdAt: user.created_at
          };
        } else {
          userInfo = { found: false };
        }
      }
      
      res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        database: {
          connected: true,
          testQuery: dbTest.rows?.[0] || dbTest[0],
          userCount: userCount?.count || 0
        },
        bcrypt: {
          working: true,
          testHash: hash.substring(0, 10) + '...',
          testValid: isValid
        },
        userInfo,
        deployment: {
          nodeVersion: process.version,
          env: process.env.NODE_ENV,
          commit: process.env.RAILWAY_GIT_COMMIT_SHA?.substring(0, 7) || 'unknown'
        }
      });
    } catch (error) {
      res.status(500).json({
        error: 'Test failed',
        message: error instanceof Error ? error.message : 'Unknown error',
        stack: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }
}