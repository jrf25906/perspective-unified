import db from '../db';
import logger from '../utils/logger';

/**
 * Activity Tracking Service
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles activity tracking and persistence
 * - OCP: Extensible for new activity types
 * - LSP: Activities are interchangeable through common interface
 * - ISP: Focused interface for activity operations
 * - DIP: Depends on database abstraction
 */

export interface ActivityEvent {
  id?: number;
  userId: number;
  type: ActivityType;
  title: string;
  description: string;
  metadata?: Record<string, any>;
  xpEarned?: number;
  timestamp: Date;
  category: ActivityCategory;
  visibility: ActivityVisibility;
}

export enum ActivityType {
  CHALLENGE_COMPLETED = 'challenge_completed',
  CHALLENGE_ATTEMPTED = 'challenge_attempted',
  STREAK_MILESTONE = 'streak_milestone',
  XP_MILESTONE = 'xp_milestone', 
  ACHIEVEMENT_UNLOCKED = 'achievement_unlocked',
  PROFILE_UPDATED = 'profile_updated',
  AVATAR_UPLOADED = 'avatar_uploaded',
  LOGIN_STREAK = 'login_streak',
  DAILY_GOAL_COMPLETED = 'daily_goal_completed',
  LEADERBOARD_RANK_IMPROVED = 'leaderboard_rank_improved',
  CHALLENGE_STREAK = 'challenge_streak',
  PERFECT_SCORE = 'perfect_score'
}

export enum ActivityCategory {
  CHALLENGE = 'challenge',
  ACHIEVEMENT = 'achievement', 
  SOCIAL = 'social',
  PROGRESS = 'progress',
  PROFILE = 'profile'
}

export enum ActivityVisibility {
  PUBLIC = 'public',
  FRIENDS = 'friends',
  PRIVATE = 'private'
}

export interface ActivitySummary {
  totalActivities: number;
  recentActivities: ActivityEvent[];
  activitiesByType: Record<ActivityType, number>;
  activitiesByCategory: Record<ActivityCategory, number>;
  lastActivityDate?: Date;
}

export interface ActivityMilestone {
  type: ActivityType;
  threshold: number;
  title: string;
  description: string;
  xpReward: number;
}

export class ActivityTrackingService {
  /**
   * Track a new activity event
   */
  static async trackActivity(activity: Omit<ActivityEvent, 'id' | 'timestamp'>): Promise<ActivityEvent> {
    try {
      const activityWithTimestamp: ActivityEvent = {
        ...activity,
        timestamp: new Date()
      };

      // Insert into database
      const [insertedId] = await db('user_activities').insert({
        user_id: activity.userId,
        type: activity.type,
        title: activity.title,
        description: activity.description,
        metadata: activity.metadata ? JSON.stringify(activity.metadata) : null,
        xp_earned: activity.xpEarned || 0,
        category: activity.category,
        visibility: activity.visibility,
        created_at: activityWithTimestamp.timestamp
      }).returning('id');

      const savedActivity = {
        ...activityWithTimestamp,
        id: insertedId?.id || insertedId
      };

      logger.info('Activity tracked', {
        userId: activity.userId,
        type: activity.type,
        activityId: savedActivity.id
      });

      // Check for milestones after tracking
      await this.checkMilestones(activity.userId, activity.type);

      return savedActivity;
    } catch (error) {
      logger.error(`Failed to track activity for user ${activity.userId}:`, error);
      throw error;
    }
  }

  /**
   * Track challenge completion activity
   */
  static async trackChallengeCompletion(
    userId: number,
    challengeId: number,
    challengeTitle: string,
    isCorrect: boolean,
    xpEarned: number,
    timeSpent?: number
  ): Promise<ActivityEvent> {
    const activity: Omit<ActivityEvent, 'id' | 'timestamp'> = {
      userId,
      type: isCorrect ? ActivityType.CHALLENGE_COMPLETED : ActivityType.CHALLENGE_ATTEMPTED,
      title: isCorrect ? 'Challenge Completed!' : 'Challenge Attempted',
      description: `${challengeTitle} - ${isCorrect ? 'Correct' : 'Incorrect'}`,
      metadata: {
        challengeId,
        challengeTitle,
        isCorrect,
        timeSpent
      },
      xpEarned: isCorrect ? xpEarned : 0,
      category: ActivityCategory.CHALLENGE,
      visibility: ActivityVisibility.PUBLIC
    };

    return this.trackActivity(activity);
  }

  /**
   * Track streak milestone
   */
  static async trackStreakMilestone(
    userId: number,
    streakLength: number,
    streakType: 'challenge' | 'login' = 'challenge'
  ): Promise<ActivityEvent> {
    const milestones = [7, 14, 30, 50, 100, 365];
    const milestone = milestones.find(m => streakLength === m);
    
    if (!milestone) {
      throw new Error('Not a milestone streak length');
    }

    const xpReward = this.calculateStreakXpReward(milestone);
    const title = this.getStreakMilestoneTitle(milestone, streakType);

    const activity: Omit<ActivityEvent, 'id' | 'timestamp'> = {
      userId,
      type: streakType === 'login' ? ActivityType.LOGIN_STREAK : ActivityType.STREAK_MILESTONE,
      title,
      description: `Maintained a ${milestone}-day ${streakType} streak!`,
      metadata: {
        streakLength: milestone,
        streakType
      },
      xpEarned: xpReward,
      category: ActivityCategory.ACHIEVEMENT,
      visibility: ActivityVisibility.PUBLIC
    };

    return this.trackActivity(activity);
  }

  /**
   * Track XP milestone
   */
  static async trackXpMilestone(userId: number, totalXp: number): Promise<ActivityEvent | null> {
    const milestones = [100, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000];
    const milestone = milestones.find(m => totalXp >= m && totalXp < m + 100); // Within 100 XP of milestone
    
    if (!milestone) {
      return null;
    }

    const activity: Omit<ActivityEvent, 'id' | 'timestamp'> = {
      userId,
      type: ActivityType.XP_MILESTONE,
      title: 'XP Milestone Reached!',
      description: `Earned ${milestone.toLocaleString()} total XP`,
      metadata: {
        milestoneXp: milestone,
        totalXp
      },
      xpEarned: Math.floor(milestone * 0.1), // 10% of milestone as bonus
      category: ActivityCategory.ACHIEVEMENT,
      visibility: ActivityVisibility.PUBLIC
    };

    return this.trackActivity(activity);
  }

  /**
   * Track avatar upload
   */
  static async trackAvatarUpload(userId: number, avatarUrl: string): Promise<ActivityEvent> {
    const activity: Omit<ActivityEvent, 'id' | 'timestamp'> = {
      userId,
      type: ActivityType.AVATAR_UPLOADED,
      title: 'Avatar Updated',
      description: 'Uploaded a new profile picture',
      metadata: {
        avatarUrl
      },
      xpEarned: 25, // Small XP reward for profile completion
      category: ActivityCategory.PROFILE,
      visibility: ActivityVisibility.FRIENDS
    };

    return this.trackActivity(activity);
  }

  /**
   * Get user activity summary
   */
  static async getActivitySummary(userId: number, limit: number = 20): Promise<ActivitySummary> {
    try {
      // Get recent activities
      const recentActivities = await db('user_activities')
        .where('user_id', userId)
        .orderBy('created_at', 'desc')
        .limit(limit)
        .select('*');

      // Transform database records to ActivityEvent objects
      const activities: ActivityEvent[] = recentActivities.map(record => ({
        id: record.id,
        userId: record.user_id,
        type: record.type as ActivityType,
        title: record.title,
        description: record.description,
        metadata: record.metadata ? JSON.parse(record.metadata) : undefined,
        xpEarned: record.xp_earned,
        timestamp: new Date(record.created_at),
        category: record.category as ActivityCategory,
        visibility: record.visibility as ActivityVisibility
      }));

      // Get total count
      const totalCount = await db('user_activities')
        .where('user_id', userId)
        .count('* as count')
        .first();

      // Get counts by type
      const typeStats = await db('user_activities')
        .where('user_id', userId)
        .select('type')
        .count('* as count')
        .groupBy('type');

      const activitiesByType: Record<ActivityType, number> = {} as any;
      typeStats.forEach(stat => {
        activitiesByType[stat.type as ActivityType] = parseInt(stat.count.toString());
      });

      // Get counts by category
      const categoryStats = await db('user_activities')
        .where('user_id', userId)
        .select('category')
        .count('* as count')
        .groupBy('category');

      const activitiesByCategory: Record<ActivityCategory, number> = {} as any;
      categoryStats.forEach(stat => {
        activitiesByCategory[stat.category as ActivityCategory] = parseInt(stat.count.toString());
      });

      // Get last activity date
      const lastActivity = activities.length > 0 ? activities[0].timestamp : undefined;

      return {
        totalActivities: parseInt(totalCount?.count?.toString() || '0'),
        recentActivities: activities,
        activitiesByType,
        activitiesByCategory,
        lastActivityDate: lastActivity
      };
    } catch (error) {
      logger.error(`Failed to get activity summary for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get public activities for social feed
   */
  static async getPublicActivities(limit: number = 50, offset: number = 0): Promise<ActivityEvent[]> {
    try {
      const activities = await db('user_activities as ua')
        .join('users as u', 'ua.user_id', 'u.id')
        .where('ua.visibility', ActivityVisibility.PUBLIC)
        .where('ua.created_at', '>', db.raw("NOW() - INTERVAL '7 days'")) // Last 7 days only
        .orderBy('ua.created_at', 'desc')
        .limit(limit)
        .offset(offset)
        .select(
          'ua.*',
          'u.username',
          'u.avatar_url'
        );

      return activities.map(record => ({
        id: record.id,
        userId: record.user_id,
        type: record.type as ActivityType,
        title: record.title,
        description: record.description,
        metadata: {
          ...record.metadata ? JSON.parse(record.metadata) : {},
          username: record.username,
          avatarUrl: record.avatar_url
        },
        xpEarned: record.xp_earned,
        timestamp: new Date(record.created_at),
        category: record.category as ActivityCategory,
        visibility: record.visibility as ActivityVisibility
      }));
    } catch (error) {
      logger.error('Failed to get public activities:', error);
      throw error;
    }
  }

  /**
   * Check for activity milestones after tracking
   */
  private static async checkMilestones(userId: number, activityType: ActivityType): Promise<void> {
    try {
      switch (activityType) {
        case ActivityType.CHALLENGE_COMPLETED:
          await this.checkChallengeCompletionMilestones(userId);
          break;
        // Add more milestone checks as needed
      }
    } catch (error) {
      logger.error(`Failed to check milestones for user ${userId}:`, error);
      // Don't throw - milestone checking shouldn't break activity tracking
    }
  }

  /**
   * Check challenge completion milestones
   */
  private static async checkChallengeCompletionMilestones(userId: number): Promise<void> {
    const completionCount = await db('user_activities')
      .where('user_id', userId)
      .where('type', ActivityType.CHALLENGE_COMPLETED)
      .count('* as count')
      .first();

    const count = parseInt(completionCount?.count?.toString() || '0');
    const milestones = [10, 25, 50, 100, 250, 500, 1000];
    
    for (const milestone of milestones) {
      if (count === milestone) {
        await this.trackActivity({
          userId,
          type: ActivityType.ACHIEVEMENT_UNLOCKED,
          title: 'Challenge Master!',
          description: `Completed ${milestone} challenges`,
          metadata: { challengeCount: milestone },
          xpEarned: milestone * 2,
          category: ActivityCategory.ACHIEVEMENT,
          visibility: ActivityVisibility.PUBLIC
        });
        break;
      }
    }
  }

  /**
   * Calculate XP reward for streak milestones
   */
  private static calculateStreakXpReward(streakLength: number): number {
    const baseReward = 50;
    const multiplier = Math.floor(streakLength / 7); // Increase reward every week
    return baseReward + (multiplier * 25);
  }

  /**
   * Get title for streak milestone
   */
  private static getStreakMilestoneTitle(streakLength: number, streakType: string): string {
    const streakTypeCapital = streakType.charAt(0).toUpperCase() + streakType.slice(1);
    
    if (streakLength >= 365) return `${streakTypeCapital} Master! 🏆`;
    if (streakLength >= 100) return `${streakTypeCapital} Legend! 🔥`;
    if (streakLength >= 50) return `${streakTypeCapital} Champion! ⭐`;
    if (streakLength >= 30) return `Monthly ${streakTypeCapital} Streak! 🎯`;
    if (streakLength >= 14) return `Two Week ${streakTypeCapital} Streak! 💪`;
    if (streakLength >= 7) return `Week ${streakTypeCapital} Streak! 🚀`;
    
    return `${streakLength}-Day ${streakTypeCapital} Streak!`;
  }
} 