import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../db';
import config from '../config';

export class DirectAuthController {
  static async testLogin(req: Request, res: Response) {
    const { email, password } = req.body;
    
    try {
      // Find user
      const user = await db('users').where({ email }).first();
      
      if (!user) {
        return res.status(404).json({ 
          error: 'User not found',
          email 
        });
      }
      
      // Check password
      const isValid = await bcrypt.compare(password, user.password_hash);
      
      if (!isValid) {
        return res.status(401).json({ 
          error: 'Invalid password',
          email 
        });
      }
      
      // Generate simple token
      const token = jwt.sign(
        { id: user.id, email: user.email },
        config.security.jwtSecret,
        { expiresIn: '1h' }
      );
      
      // Return minimal response
      res.json({
        success: true,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          echoScore: user.echo_score || 0
        },
        token
      });
      
    } catch (error) {
      res.status(500).json({
        error: 'Direct login error',
        message: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
  
  static async testRegister(req: Request, res: Response) {
    // Handle both camelCase (from iOS) and snake_case (from middleware)
    const email = req.body.email;
    const username = req.body.username;
    const password = req.body.password;
    const firstName = req.body.firstName || req.body.first_name;
    const lastName = req.body.lastName || req.body.last_name;
    
    try {
      // Check if user exists
      const existing = await db('users').where({ email }).orWhere({ username }).first();
      
      if (existing) {
        return res.status(400).json({
          error: 'User already exists',
          email: existing.email === email,
          username: existing.username === username
        });
      }
      
      // Hash password
      const passwordHash = await bcrypt.hash(password, 10);
      
      // Create user with minimal fields
      const userData = {
        email,
        username,
        password_hash: passwordHash,
        first_name: firstName || null,
        last_name: lastName || null,
        echo_score: 0,
        current_streak: 0,
        created_at: new Date(),
        updated_at: new Date()
      };

      let user;
      if (db.client.config.client === 'postgresql') {
        const result = await db('users').insert(userData).returning(['id', 'email', 'username']);
        user = result[0];
      } else {
        const [id] = await db('users').insert(userData);
        user = await db('users').where({ id }).first();
      }
      
      // Generate token
      const token = jwt.sign(
        { id: user.id, email: user.email },
        config.security.jwtSecret,
        { expiresIn: '1h' }
      );
      
      res.status(201).json({
        success: true,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          echoScore: 0
        },
        token
      });
      
    } catch (error) {
      res.status(500).json({
        error: 'Direct registration error',
        message: error instanceof Error ? error.message : 'Unknown error',
        details: error
      });
    }
  }
}