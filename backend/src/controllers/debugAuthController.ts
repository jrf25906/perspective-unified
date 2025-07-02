import { Request, Response } from 'express';
import logger from '../utils/logger';
import bcrypt from 'bcryptjs';
import db from '../db';

export const debugRegister = async (req: Request, res: Response) => {
  try {
    const { email, username, password, first_name, last_name } = req.body;
    
    logger.info('Debug register attempt:', { email, username, first_name, last_name });

    // Test 1: Can we query the users table?
    try {
      const userCount = await db('users').count('* as count');
      logger.info('Users table count:', userCount);
    } catch (dbError) {
      logger.error('Cannot query users table:', dbError);
      return res.status(500).json({
        error: {
          code: 'DB_TABLE_ERROR',
          message: 'Cannot access users table',
          details: dbError instanceof Error ? dbError.message : 'Unknown error'
        }
      });
    }

    // Test 2: Check if user exists
    try {
      const existing = await db('users')
        .where('email', email)
        .orWhere('username', username)
        .first();
      
      if (existing) {
        return res.status(409).json({
          error: {
            code: 'USER_EXISTS',
            message: 'User already exists'
          }
        });
      }
    } catch (queryError) {
      logger.error('Error checking existing user:', queryError);
    }

    // Test 3: Try to insert user
    try {
      const hashedPassword = await bcrypt.hash(password, 12);
      
      // Try different insert methods based on database
      const client = db.client.config.client;
      logger.info('Database client:', client);
      
      let newUser;
      if (client === 'postgresql') {
        // PostgreSQL supports RETURNING
        const result = await db('users')
          .insert({
            email,
            username,
            password_hash: hashedPassword,
            first_name,
            last_name,
            created_at: new Date(),
            updated_at: new Date()
          })
          .returning('*');
        newUser = result[0];
      } else {
        // For other databases, insert then query
        const [id] = await db('users')
          .insert({
            email,
            username,
            password_hash: hashedPassword,
            first_name,
            last_name,
            created_at: new Date(),
            updated_at: new Date()
          });
        
        newUser = await db('users').where({ id }).first();
      }
      
      logger.info('User created successfully:', { id: newUser.id, email: newUser.email });
      
      return res.json({
        success: true,
        user: {
          id: newUser.id,
          email: newUser.email,
          username: newUser.username
        }
      });
      
    } catch (insertError) {
      logger.error('Failed to insert user:', insertError);
      return res.status(500).json({
        error: {
          code: 'INSERT_FAILED',
          message: 'Failed to create user in database',
          details: insertError instanceof Error ? insertError.message : 'Unknown error'
        }
      });
    }
    
  } catch (error) {
    logger.error('Debug register error:', error);
    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Registration failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      }
    });
  }
};