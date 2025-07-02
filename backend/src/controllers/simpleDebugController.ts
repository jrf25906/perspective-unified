import { Request, Response } from 'express';
import db from '../db';
import bcrypt from 'bcryptjs';

export class SimpleDebugController {
  static async checkUser(req: Request, res: Response) {
    const { email, password } = req.body;
    
    try {
      // Get all users
      const users = await db('users')
        .select('id', 'email', 'username', 'password_hash', 'created_at')
        .orderBy('created_at', 'desc')
        .limit(10);
      
      // Check specific user if email provided
      let userCheck = null;
      if (email) {
        const user = await db('users').where({ email }).first();
        if (user && password) {
          const isValid = await bcrypt.compare(password, user.password_hash);
          userCheck = {
            found: true,
            passwordValid: isValid,
            hashLength: user.password_hash?.length,
            hashPrefix: user.password_hash?.substring(0, 10) + '...'
          };
        } else {
          userCheck = { found: !!user };
        }
      }
      
      res.json({
        totalUsers: users.length,
        recentUsers: users.map(u => ({
          id: u.id,
          email: u.email.replace(/^(.{3}).*@/, '$1***@'),
          username: u.username,
          hasPassword: !!u.password_hash,
          createdAt: u.created_at
        })),
        userCheck,
        requestedEmail: email
      });
    } catch (error) {
      res.status(500).json({
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
}