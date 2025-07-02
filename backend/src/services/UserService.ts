import db from '../db';
import { User } from '../models/User';

export class UserService {
  static async findByEmailOrUsername(email: string, username: string): Promise<User | undefined> {
    return db<User>('users')
      .where('email', email)
      .orWhere('username', username)
      .first();
  }

  static async create(userData: Partial<User>): Promise<User> {
    // Ensure timestamps are set
    const dataWithTimestamps = {
      ...userData,
      created_at: userData.created_at || new Date(),
      updated_at: userData.updated_at || new Date()
    };

    // PostgreSQL supports RETURNING, others need a separate query
    if (db.client.config.client === 'postgresql') {
      const [user] = await db<User>('users')
        .insert(dataWithTimestamps)
        .returning('*');
      return user;
    } else {
      // For SQLite and others, insert then query
      const [id] = await db<User>('users')
        .insert(dataWithTimestamps);
      
      const user = await db<User>('users').where({ id }).first();
      if (!user) {
        throw new Error('Failed to retrieve created user');
      }
      return user;
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
