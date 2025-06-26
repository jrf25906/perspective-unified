import express from 'express';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { ActivityTrackingService } from '../services/ActivityTrackingService';
import logger from '../utils/logger';

const router = express.Router();

/**
 * Activity Routes
 * 
 * Provides access to user activity tracking and social feeds
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles activity-related HTTP operations
 * - OCP: Extensible for new activity endpoints
 * - DIP: Depends on ActivityTrackingService abstraction
 */

/**
 * Get user's activity summary
 * GET /api/activity/summary?limit=20
 */
router.get('/summary', authenticateToken, async (req: AuthenticatedRequest, res) => {
  const correlationId = (req as any).correlationId || 'unknown';
  
  try {
    if (!req.user) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    const limit = parseInt(req.query.limit as string) || 20;
    
    if (limit > 100) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Limit cannot exceed 100'
        }
      });
    }

    logger.debug('Activity summary requested', {
      correlationId,
      userId: req.user.id,
      limit
    });

    const activitySummary = await ActivityTrackingService.getActivitySummary(req.user.id, limit);

    res.json({
      success: true,
      data: activitySummary
    });

  } catch (error) {
    logger.error('Get activity summary failed', {
      correlationId,
      userId: req.user?.id,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to get activity summary'
      }
    });
  }
});

/**
 * Get user's recent activities
 * GET /api/activity/recent?limit=10
 */
router.get('/recent', authenticateToken, async (req: AuthenticatedRequest, res) => {
  const correlationId = (req as any).correlationId || 'unknown';
  
  try {
    if (!req.user) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    const limit = parseInt(req.query.limit as string) || 10;
    
    if (limit > 50) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Limit cannot exceed 50'
        }
      });
    }

    logger.debug('Recent activities requested', {
      correlationId,
      userId: req.user.id,
      limit
    });

    const activitySummary = await ActivityTrackingService.getActivitySummary(req.user.id, limit);

    res.json({
      success: true,
      data: {
        activities: activitySummary.recentActivities,
        totalCount: activitySummary.totalActivities
      }
    });

  } catch (error) {
    logger.error('Get recent activities failed', {
      correlationId,
      userId: req.user?.id,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to get recent activities'
      }
    });
  }
});

/**
 * Get public activity feed
 * GET /api/activity/feed?limit=50&offset=0
 */
router.get('/feed', async (req, res) => {
  const correlationId = (req as any).correlationId || 'unknown';
  
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    
    if (limit > 100) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Limit cannot exceed 100'
        }
      });
    }

    if (offset < 0) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Offset cannot be negative'
        }
      });
    }

    logger.debug('Public activity feed requested', {
      correlationId,
      limit,
      offset
    });

    const publicActivities = await ActivityTrackingService.getPublicActivities(limit, offset);

    res.json({
      success: true,
      data: {
        activities: publicActivities,
        limit,
        offset,
        hasMore: publicActivities.length === limit
      }
    });

  } catch (error) {
    logger.error('Get public activity feed failed', {
      correlationId,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to get activity feed'
      }
    });
  }
});

/**
 * Track custom activity (for testing/admin purposes)
 * POST /api/activity/track
 */
router.post('/track', authenticateToken, async (req: AuthenticatedRequest, res) => {
  const correlationId = (req as any).correlationId || 'unknown';
  
  try {
    if (!req.user) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        }
      });
    }

    const { type, title, description, xpEarned, category, visibility, metadata } = req.body;

    // Validate required fields
    if (!type || !title || !description || !category || !visibility) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'type, title, description, category, and visibility are required'
        }
      });
    }

    logger.info('Custom activity tracking requested', {
      correlationId,
      userId: req.user.id,
      type,
      title
    });

    const activity = await ActivityTrackingService.trackActivity({
      userId: req.user.id,
      type,
      title,
      description,
      xpEarned: xpEarned || 0,
      category,
      visibility,
      metadata
    });

    res.status(201).json({
      success: true,
      data: activity,
      message: 'Activity tracked successfully'
    });

  } catch (error) {
    logger.error('Track custom activity failed', {
      correlationId,
      userId: req.user?.id,
      error: error instanceof Error ? error.message : 'Unknown error'
    });

    res.status(500).json({
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to track activity'
      }
    });
  }
});

export default router; 