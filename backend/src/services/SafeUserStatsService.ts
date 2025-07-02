import db from '../db';
import logger from '../utils/logger';
import { UserStats, RecentActivity, StreakInfo } from './UserStatsService';

/**
 * SafeUserStatsService - A failsafe version of UserStatsService
 * 
 * This service provides user statistics with graceful fallbacks
 * to prevent registration/login failures when stats tables are missing
 * or when database compatibility issues arise (e.g., JSONB in SQLite).
 */
export class SafeUserStatsService {
  /**
   * Get user stats with graceful fallback
   */
  static async getUserStats(userId: number): Promise<UserStats> {
    try {
      logger.debug(`SafeUserStatsService: Getting stats for user ${userId}`);
      
      // Try to get stats from user_challenge_stats table
      const stats = await this.getStatsFromTable(userId);
      if (stats) {
        return stats;
      }
      
      // If table doesn't exist or query fails, return default stats
      return this.getDefaultStats(userId);
      
    } catch (error) {
      logger.warn(`SafeUserStatsService: Failed to get stats for user ${userId}, using defaults:`, error);
      return this.getDefaultStats(userId);
    }
  }
  
  /**
   * Try to get stats from user_challenge_stats table
   */
  private static async getStatsFromTable(userId: number): Promise<UserStats | null> {
    try {
      // Check if table exists first
      const tableExists = await this.checkTableExists('user_challenge_stats');
      if (!tableExists) {
        logger.debug('SafeUserStatsService: user_challenge_stats table does not exist');
        return null;
      }
      
      // Get base stats
      const stats = await db('user_challenge_stats')
        .where('user_id', userId)
        .select('total_completed', 'total_correct', 'current_streak', 'longest_streak', 'last_challenge_date')
        .first();
      
      if (!stats) {
        // No stats record exists for user yet
        return null;
      }
      
      // Calculate derived stats
      const averageAccuracy = stats.total_completed > 0 
        ? (stats.total_correct / stats.total_completed) * 100 
        : 0;
      
      // Get XP from challenge_submissions if table exists
      const totalXpEarned = await this.getTotalXpEarned(userId);
      
      // Get recent activity
      const recentActivity = await this.getRecentActivity(userId);
      
      return {
        totalChallengesCompleted: stats.total_completed || 0,
        totalCorrect: stats.total_correct || 0,
        currentStreak: stats.current_streak || 0,
        longestStreak: stats.longest_streak || 0,
        totalXpEarned,
        averageAccuracy: Math.round(averageAccuracy * 100) / 100,
        recentActivity,
        streakInfo: {
          current: stats.current_streak || 0,
          longest: stats.longest_streak || 0,
          isActive: this.isStreakActive(stats.last_challenge_date),
          lastActivityDate: stats.last_challenge_date ? new Date(stats.last_challenge_date) : undefined
        }
      };
      
    } catch (error) {
      logger.debug('SafeUserStatsService: Error getting stats from table:', error);
      return null;
    }
  }
  
  /**
   * Check if a table exists in the database
   */
  private static async checkTableExists(tableName: string): Promise<boolean> {
    try {
      const exists = await db.schema.hasTable(tableName);
      return exists;
    } catch (error) {
      logger.debug(`SafeUserStatsService: Error checking if table ${tableName} exists:`, error);
      return false;
    }
  }
  
  /**
   * Get total XP earned from challenge_submissions
   */
  private static async getTotalXpEarned(userId: number): Promise<number> {
    try {
      const tableExists = await this.checkTableExists('challenge_submissions');
      if (!tableExists) {
        return 0;
      }
      
      const result = await db('challenge_submissions')
        .where('user_id', userId)
        .sum('xp_earned as total')
        .first();
      
      return result?.total || 0;
      
    } catch (error) {
      logger.debug('SafeUserStatsService: Error getting total XP:', error);
      return 0;
    }
  }
  
  /**
   * Get recent activity for user
   */
  private static async getRecentActivity(userId: number, limit: number = 10): Promise<RecentActivity[]> {
    try {
      const tableExists = await this.checkTableExists('challenge_submissions');
      if (!tableExists) {
        return [];
      }
      
      const activities = await db('challenge_submissions as cs')
        .leftJoin('challenges as c', 'cs.challenge_id', 'c.id')
        .where('cs.user_id', userId)
        .whereNotNull('cs.completed_at')
        .select(
          'cs.id',
          'cs.completed_at',
          'cs.is_correct',
          'cs.xp_earned',
          'c.title as challenge_title'
        )
        .orderBy('cs.completed_at', 'desc')
        .limit(limit);
      
      return activities.map(activity => ({
        id: activity.id,
        type: 'challenge_completed' as const,
        title: activity.is_correct ? 'Challenge Completed!' : 'Challenge Attempted',
        description: activity.challenge_title || 'Unknown Challenge',
        xpEarned: activity.xp_earned || 0,
        timestamp: new Date(activity.completed_at),
        metadata: {
          isCorrect: activity.is_correct
        }
      }));
      
    } catch (error) {
      logger.debug('SafeUserStatsService: Error getting recent activity:', error);
      return [];
    }
  }
  
  /**
   * Check if streak is still active (within last 48 hours)
   */
  private static isStreakActive(lastChallengeDate: Date | string | null): boolean {
    if (!lastChallengeDate) return false;
    
    const lastDate = new Date(lastChallengeDate);
    const now = new Date();
    const hoursDiff = (now.getTime() - lastDate.getTime()) / (1000 * 60 * 60);
    
    return hoursDiff < 48;
  }
  
  /**
   * Get default stats for a user (used as fallback)
   */
  private static getDefaultStats(userId: number): UserStats {
    logger.debug(`SafeUserStatsService: Returning default stats for user ${userId}`);
    
    return {
      totalChallengesCompleted: 0,
      totalCorrect: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalXpEarned: 0,
      averageAccuracy: 0,
      recentActivity: [],
      streakInfo: {
        current: 0,
        longest: 0,
        isActive: false
      }
    };
  }
}