import { Request, Response } from 'express';
import { AuthenticatedRequest } from '../middleware/auth';
import { container, ServiceTokens } from '../di/container';
import { IAvatarService } from '../interfaces/IAvatarService';
import logger from '../utils/logger';

/**
 * Avatar Controller
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles avatar-related HTTP operations
 * - OCP: Extensible for new avatar operations
 * - LSP: Uses IAvatarService abstraction
 * - ISP: Focused interface for avatar operations
 * - DIP: Depends on abstractions, not concrete implementations
 */
export class AvatarController {
  private static get avatarService(): IAvatarService {
    return container.get(ServiceTokens.AvatarService);
  }

  /**
   * Upload user avatar
   * POST /api/avatar/upload
   */
  static async uploadAvatar(req: AuthenticatedRequest, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    const startTime = Date.now();

    try {
      if (!req.user) {
        return res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Authentication required'
          }
        });
      }

      if (!req.file) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Avatar image file is required'
          }
        });
      }

      logger.info('Avatar upload initiated', {
        correlationId,
        userId: req.user.id,
        fileName: req.file.originalname,
        fileSize: req.file.size,
        mimeType: req.file.mimetype
      });

      // Upload and process avatar
      const avatarUrl = await this.avatarService.uploadUserAvatar(req.user.id, req.file);

      logger.info('Avatar upload successful', {
        correlationId,
        userId: req.user.id,
        avatarUrl,
        duration: Date.now() - startTime
      });

      res.status(200).json({
        success: true,
        avatarUrl,
        message: 'Avatar uploaded successfully'
      });

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Avatar upload failed';
      
      logger.error('Avatar upload failed', {
        correlationId,
        userId: req.user?.id,
        error: error instanceof Error ? {
          message: error.message,
          stack: error.stack,
          name: error.name
        } : error,
        duration: Date.now() - startTime
      });

      // Map specific errors to appropriate HTTP status codes
      let statusCode = 500;
      let errorCode = 'INTERNAL_ERROR';

      if (errorMessage.includes('File size exceeds')) {
        statusCode = 413;
        errorCode = 'FILE_TOO_LARGE';
      } else if (errorMessage.includes('Invalid file type') || 
                 errorMessage.includes('Invalid image file')) {
        statusCode = 400;
        errorCode = 'INVALID_FILE_TYPE';
      } else if (errorMessage.includes('Image must')) {
        statusCode = 400;
        errorCode = 'INVALID_IMAGE_DIMENSIONS';
      }

      res.status(statusCode).json({
        error: {
          code: errorCode,
          message: errorMessage
        }
      });
    }
  }

  /**
   * Delete user avatar
   * DELETE /api/avatar
   */
  static async deleteAvatar(req: AuthenticatedRequest, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';
    const startTime = Date.now();

    try {
      if (!req.user) {
        return res.status(401).json({
          error: {
            code: 'UNAUTHORIZED',
            message: 'Authentication required'
          }
        });
      }

      logger.info('Avatar deletion initiated', {
        correlationId,
        userId: req.user.id
      });

      await this.avatarService.deleteUserAvatar(req.user.id);

      logger.info('Avatar deletion successful', {
        correlationId,
        userId: req.user.id,
        duration: Date.now() - startTime
      });

      res.status(200).json({
        success: true,
        message: 'Avatar deleted successfully'
      });

    } catch (error) {
      logger.error('Avatar deletion failed', {
        correlationId,
        userId: req.user?.id,
        error: error instanceof Error ? {
          message: error.message,
          stack: error.stack,
          name: error.name
        } : error,
        duration: Date.now() - startTime
      });

      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to delete avatar'
        }
      });
    }
  }

  /**
   * Get user avatar URL
   * GET /api/avatar/:userId?
   */
  static async getAvatarUrl(req: Request, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';

    try {
      const userIdParam = req.params.userId;
      const authenticatedReq = req as AuthenticatedRequest;
      
      // Determine target user ID
      let targetUserId: number;
      if (userIdParam) {
        targetUserId = parseInt(userIdParam, 10);
        if (isNaN(targetUserId)) {
          return res.status(400).json({
            error: {
              code: 'VALIDATION_ERROR', 
              message: 'Invalid user ID'
            }
          });
        }
      } else {
        // Get own avatar - requires authentication
        if (!authenticatedReq.user) {
          return res.status(401).json({
            error: {
              code: 'UNAUTHORIZED',
              message: 'Authentication required'
            }
          });
        }
        targetUserId = authenticatedReq.user.id;
      }

      logger.debug('Avatar URL request', {
        correlationId,
        targetUserId,
        requesterId: authenticatedReq.user?.id
      });

      const avatarUrl = await this.avatarService.getAvatarUrl(targetUserId);

      res.status(200).json({
        userId: targetUserId,
        avatarUrl: avatarUrl || null,
        hasAvatar: !!avatarUrl
      });

    } catch (error) {
      logger.error('Get avatar URL failed', {
        correlationId,
        error: error instanceof Error ? {
          message: error.message,
          stack: error.stack,
          name: error.name
        } : error
      });

      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to get avatar URL'
        }
      });
    }
  }

  /**
   * Get avatar URL with Gravatar fallback
   * GET /api/avatar/:userId/with-fallback
   */
  static async getAvatarUrlWithFallback(req: Request, res: Response) {
    const correlationId = (req as any).correlationId || 'unknown';

    try {
      const userIdParam = req.params.userId;
      const size = parseInt(req.query.size as string) || 200;
      
      if (!userIdParam) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'User ID is required'
          }
        });
      }

      const userId = parseInt(userIdParam, 10);
      if (isNaN(userId)) {
        return res.status(400).json({
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid user ID'
          }
        });
      }

      // Get user email for Gravatar fallback
      const user = await container.get(ServiceTokens.Database)('users')
        .where('id', userId)
        .select('email')
        .first();

      if (!user) {
        return res.status(404).json({
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found'
          }
        });
      }

      logger.debug('Avatar URL with fallback request', {
        correlationId,
        userId,
        size
      });

      const avatarUrl = await this.avatarService.getAvatarUrlWithFallback(
        userId,
        user.email,
        size
      );

      res.status(200).json({
        userId,
        avatarUrl,
        isGravatar: !await this.avatarService.getAvatarUrl(userId)
      });

    } catch (error) {
      logger.error('Get avatar URL with fallback failed', {
        correlationId,
        error: error instanceof Error ? {
          message: error.message,
          stack: error.stack,
          name: error.name
        } : error
      });

      res.status(500).json({
        error: {
          code: 'INTERNAL_ERROR', 
          message: 'Failed to get avatar URL'
        }
      });
    }
  }
} 