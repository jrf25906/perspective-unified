import db from '../db';
import { User } from '../models/User';
import logger from '../utils/logger';

export class UserService {
  static async findByEmailOrUsername(email: string, username: string): Promise<User | undefined> {
    return db<User>('users')
      .where('email', email)
      .orWhere('username', username)
      .first();
  }

  static async create(userData: Partial<User>): Promise<User> {
    // Ensure all required fields have default values
    const dataWithDefaults = {
      ...userData,
      created_at: userData.created_at || new Date(),
      updated_at: userData.updated_at || new Date(),
      is_active: userData.is_active !== undefined ? userData.is_active : true,
      email_verified: userData.email_verified !== undefined ? userData.email_verified : false,
      echo_score: userData.echo_score !== undefined ? userData.echo_score : 0,
      current_streak: userData.current_streak !== undefined ? userData.current_streak : 0,
      // Ensure password_hash is either a string or null (not undefined)
      password_hash: userData.password_hash === undefined ? null : userData.password_hash
    };

    try {
      // PostgreSQL supports RETURNING, others need a separate query
      if (db.client.config.client === 'postgresql') {
        const [user] = await db<User>('users')
          .insert(dataWithDefaults)
          .returning('*');
        return user;
      } else {
        // For SQLite and others, insert then query
        const [id] = await db<User>('users')
          .insert(dataWithDefaults);
        
        const user = await db<User>('users').where({ id }).first();
        if (!user) {
          throw new Error('Failed to retrieve created user');
        }
        return user;
      }
    } catch (error) {
      logger.error('UserService.create failed:', {
        error: error instanceof Error ? {
          message: error.message,
          code: (error as any).code,
          detail: (error as any).detail,
          constraint: (error as any).constraint,
          column: (error as any).column,
          table: (error as any).table
        } : error,
        userData: {
          email: userData.email,
          username: userData.username,
          hasPassword: !!userData.password_hash,
          fields: Object.keys(dataWithDefaults)
        }
      });
      throw error;
    }
  }

  static async findByEmail(email: string): Promise<User | undefined> {
    return db<User>('users').where({ email }).first();
  }

  static async findByUsername(username: string): Promise<User | undefined> {
    return db<User>('users').where({ username }).first();
  }

  static async findById(id: number): Promise<User | undefined> {
    return db<User>('users').where({ id }).first();
  }

  static async updateLastActivity(id: number): Promise<void> {
    await db('users')
      .where({ id })
      .update({ last_activity_date: db.fn.now(), updated_at: db.fn.now() });
  }

  static async updateGoogleInfo(id: number, googleInfo: { google_id: string; avatar_url?: string; email_verified?: boolean }): Promise<void> {
    await db('users')
      .where({ id })
      .update({ 
        ...googleInfo, 
        updated_at: db.fn.now() 
      });
  }

  static async updateProfile(id: number, profileData: Partial<User>): Promise<User> {
    const updateData = {
      ...profileData,
      updated_at: db.fn.now()
    };

    if (db.client.config.client === 'postgresql') {
      const [updatedUser] = await db<User>('users')
        .where({ id })
        .update(updateData)
        .returning('*');
      
      if (!updatedUser) {
        throw new Error('User not found');
      }
      
      return updatedUser;
    } else {
      // For SQLite and others, update then query
      await db<User>('users')
        .where({ id })
        .update(updateData);
      
      const updatedUser = await db<User>('users').where({ id }).first();
      if (!updatedUser) {
        throw new Error('User not found');
      }
      
      return updatedUser;
    }
  }

  static async isEmailTaken(email: string, excludeUserId?: number): Promise<boolean> {
    const query = db<User>('users').where({ email });
    
    if (excludeUserId) {
      query.andWhere('id', '!=', excludeUserId);
    }
    
    const user = await query.first();
    return !!user;
  }

  static async isUsernameTaken(username: string, excludeUserId?: number): Promise<boolean> {
    const query = db<User>('users').where({ username });
    
    if (excludeUserId) {
      query.andWhere('id', '!=', excludeUserId);
    }
    
    const user = await query.first();
    return !!user;
  }

  static async getUserStats(id: number): Promise<{
    totalChallengesCompleted: number;
    averageAccuracy: number;
    totalTimeSpent: number;
  }> {
    // This is a placeholder - in a real app you'd query the challenges/submissions tables
    // For now, return mock data
    return {
      totalChallengesCompleted: 0,
      averageAccuracy: 0,
      totalTimeSpent: 0
    };
  }

  static async getRecentUsers(limit: number = 10): Promise<User[]> {
    return db<User>('users')
      .orderBy('created_at', 'desc')
      .limit(limit);
  }
}
