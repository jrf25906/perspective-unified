import express from 'express';
import multer from 'multer';
import { authenticateToken } from '../middleware/auth';
import { AvatarController } from '../controllers/avatarController';

/**
 * Avatar Routes
 * 
 * RESTful API design following SOLID principles:
 * - SRP: Only handles avatar-related routing
 * - OCP: Extensible for new avatar operations
 * - DIP: Depends on controller abstraction
 */

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 1
  },
  fileFilter: (req, file, cb) => {
    // Allow only image files
    const allowedMimeTypes = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'image/gif',
      'image/webp'
    ];
    
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only images are allowed.'));
    }
  }
});

/**
 * Avatar upload endpoint
 * POST /api/avatar/upload
 * 
 * Requires:
 * - Authentication token
 * - Multipart form data with 'avatar' field
 * 
 * Returns:
 * - 200: { success: true, avatarUrl: string, message: string }
 * - 400: { error: { code: string, message: string } }
 * - 401: { error: { code: 'UNAUTHORIZED', message: string } }
 * - 413: { error: { code: 'FILE_TOO_LARGE', message: string } }
 */
router.post('/upload', 
  authenticateToken,
  upload.single('avatar'),
  AvatarController.uploadAvatar
);

/**
 * Delete avatar endpoint
 * DELETE /api/avatar
 * 
 * Requires:
 * - Authentication token
 * 
 * Returns:
 * - 200: { success: true, message: string }
 * - 401: { error: { code: 'UNAUTHORIZED', message: string } }
 * - 500: { error: { code: 'INTERNAL_ERROR', message: string } }
 */
router.delete('/', 
  authenticateToken,
  AvatarController.deleteAvatar
);

/**
 * Get own avatar URL
 * GET /api/avatar
 * 
 * Requires:
 * - Authentication token
 * 
 * Returns:
 * - 200: { userId: number, avatarUrl: string | null, hasAvatar: boolean }
 * - 401: { error: { code: 'UNAUTHORIZED', message: string } }
 */
router.get('/', 
  authenticateToken,
  AvatarController.getAvatarUrl
);

/**
 * Get specific user's avatar URL (public endpoint)
 * GET /api/avatar/:userId
 * 
 * No authentication required for public avatar viewing
 * 
 * Returns:
 * - 200: { userId: number, avatarUrl: string | null, hasAvatar: boolean }
 * - 400: { error: { code: 'VALIDATION_ERROR', message: string } }
 */
router.get('/:userId', 
  AvatarController.getAvatarUrl
);

/**
 * Get avatar URL with Gravatar fallback
 * GET /api/avatar/:userId/with-fallback?size=200
 * 
 * Public endpoint that always returns an avatar URL
 * Falls back to Gravatar if no uploaded avatar exists
 * 
 * Query parameters:
 * - size: number (optional, default: 200) - Avatar size in pixels
 * 
 * Returns:
 * - 200: { userId: number, avatarUrl: string, isGravatar: boolean }
 * - 400: { error: { code: 'VALIDATION_ERROR', message: string } }
 * - 404: { error: { code: 'USER_NOT_FOUND', message: string } }
 */
router.get('/:userId/with-fallback',
  AvatarController.getAvatarUrlWithFallback
);

// Error handling middleware for multer errors
router.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  if (error instanceof multer.MulterError) {
    let errorCode = 'UPLOAD_ERROR';
    let statusCode = 400;
    let message = error.message;

    switch (error.code) {
      case 'LIMIT_FILE_SIZE':
        statusCode = 413;
        errorCode = 'FILE_TOO_LARGE';
        message = 'File size exceeds 5MB limit';
        break;
      case 'LIMIT_FILE_COUNT':
        errorCode = 'TOO_MANY_FILES';
        message = 'Only one file allowed';
        break;
      case 'LIMIT_UNEXPECTED_FILE':
        errorCode = 'UNEXPECTED_FILE';
        message = 'Unexpected field name. Use "avatar" field for file upload';
        break;
    }

    return res.status(statusCode).json({
      error: {
        code: errorCode,
        message
      }
    });
  }
  
  // Handle file filter errors
  if (error.message === 'Invalid file type. Only images are allowed.') {
    return res.status(400).json({
      error: {
        code: 'INVALID_FILE_TYPE',
        message: 'Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.'
      }
    });
  }

  // Pass to next error handler
  next(error);
});

export default router; 