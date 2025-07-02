import { Request, Response, NextFunction } from 'express';

import logger from '../utils/logger';
const errorHandler = (error: any, req: Request, res: Response, next: NextFunction): void => {
  // Prevent recursive error logging for already-stringified error objects
  const isRecursiveError = typeof error.message === 'string' && 
    (error.message.includes('{\\"error\\":{') || 
     error.message.includes('{"error":{') ||
     error.message.length > 1000);
  
  if (isRecursiveError) {
    logger.error(`[${req.requestId}] Recursive error detected - logging truncated to prevent infinite loop`);
    // Extract just the core error message if possible
    try {
      const parsed = JSON.parse(error.message);
      if (parsed.error && parsed.error.message) {
        logger.error(`[${req.requestId}] Core error: ${parsed.error.message}`);
      }
    } catch (e) {
      // If parsing fails, just log that we prevented recursion
    }
  } else {
    logger.error(`[${req.requestId}] Error:`, error.stack);
  }

  const status = error.status || 500;
  const message = error.message || 'Internal Server Error';

  const errorResponse: any = {
    error: {
      code: error.code || 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : message,
      timestamp: new Date().toISOString(),
      requestId: req.requestId,
    },
  };

  if (process.env.NODE_ENV === 'development') {
    errorResponse.error.stack = error.stack;
  }

  res.status(status).json(errorResponse);
};

export default errorHandler;
