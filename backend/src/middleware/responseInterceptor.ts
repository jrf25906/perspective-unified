import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

interface ErrorResponse {
  error: {
    code: string;
    message: string;
    correlationId?: string;
    validationErrors?: any[];
    details?: any;
  };
}

/**
 * Event-based response interceptor middleware - NO method overriding to prevent conflicts
 * Uses Express events to track responses without interfering with other middleware
 */
export function responseInterceptor(req: Request, res: Response, next: NextFunction): void {
  // Generate correlation ID if not present
  const correlationId = req.headers['x-correlation-id'] as string || 
    req.headers['x-request-id'] as string || 
    generateCorrelationId();
  
  // Add correlation ID to response headers
  res.setHeader('X-Correlation-ID', correlationId);
  
  // Store correlation ID for logging
  (req as any).correlationId = correlationId;
  
  // Use event-based approach - listen for response completion
  res.on('finish', () => {
    // Log error responses after they're sent (no recursion risk)
    if (res.statusCode >= 400) {
      logger.error('Error response sent', {
        correlationId,
        statusCode: res.statusCode,
        path: req.path,
        method: req.method,
        userAgent: req.get('User-Agent'),
        ip: req.ip
      });
    }
  });
  
  next();
}

/**
 * Response formatter utility - call this from route handlers for consistent error formatting
 * This replaces the method overriding approach and prevents middleware conflicts
 */
export function formatErrorResponse(res: Response, statusCode: number, data: any, correlationId?: string): Response {
  const finalCorrelationId = correlationId || res.getHeader('X-Correlation-ID') as string || generateCorrelationId();
  
  // Set correlation ID if not already set
  if (!res.getHeader('X-Correlation-ID')) {
    res.setHeader('X-Correlation-ID', finalCorrelationId);
  }
  
  let formattedData = data;
  
  if (data && !data.error) {
    // Transform non-standard error responses
    const errorResponse: ErrorResponse = {
      error: {
        code: determineErrorCode(statusCode, data),
        message: extractErrorMessage(data),
        correlationId: finalCorrelationId
      }
    };
    
    // Add validation errors if present
    if (data.validationErrors || data.errors) {
      errorResponse.error.validationErrors = data.validationErrors || data.errors;
    }
    
    // Add details if present and not redundant
    if (data.details && typeof data.details === 'object') {
      errorResponse.error.details = data.details;
    }
    
    formattedData = errorResponse;
  } else if (data && data.error) {
    // Ensure error has correlation ID
    data.error.correlationId = data.error.correlationId || finalCorrelationId;
    
    // Ensure error has code
    if (!data.error.code) {
      data.error.code = determineErrorCode(statusCode, data.error);
    }
    formattedData = data;
  }
  
  return res.status(statusCode).json(formattedData);
}

/**
 * Generate a unique correlation ID
 */
function generateCorrelationId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Determine error code based on status code and data
 */
function determineErrorCode(statusCode: number, data: any): string {
  // Check if data already has a code
  if (data.code && typeof data.code === 'string') {
    return data.code;
  }
  
  // Map status codes to error codes
  switch (statusCode) {
    case 400:
      return 'VALIDATION_ERROR';
    case 401:
      return 'UNAUTHORIZED';
    case 403:
      return 'FORBIDDEN';
    case 404:
      return 'NOT_FOUND';
    case 409:
      return 'CONFLICT';
    case 429:
      return 'RATE_LIMIT_EXCEEDED';
    case 500:
      return 'INTERNAL_ERROR';
    case 502:
      return 'BAD_GATEWAY';
    case 503:
      return 'SERVICE_UNAVAILABLE';
    default:
      return statusCode >= 500 ? 'SERVER_ERROR' : 'CLIENT_ERROR';
  }
}

/**
 * Extract error message from various data formats
 */
function extractErrorMessage(data: any): string {
  // If data is a string, use it directly
  if (typeof data === 'string') {
    return data;
  }
  
  // Check common error message properties
  if (data.message) {
    return data.message;
  }
  
  if (data.error && typeof data.error === 'string') {
    return data.error;
  }
  
  if (data.error && data.error.message) {
    return data.error.message;
  }
  
  if (data.msg) {
    return data.msg;
  }
  
  if (data.reason) {
    return data.reason;
  }
  
  if (data.detail) {
    return data.detail;
  }
  
  // If data is an array (validation errors), join them
  if (Array.isArray(data)) {
    return data.map(err => err.message || err.msg || err).join(', ');
  }
  
  // Default message
  return 'An error occurred';
}

/**
 * Error correlation middleware to track errors across requests
 */
export function errorCorrelationMiddleware(req: Request, res: Response, next: NextFunction): void {
  // Generate or extract correlation ID
  const correlationId = req.headers['x-correlation-id'] as string || 
    req.headers['x-request-id'] as string || 
    generateCorrelationId();
  
  // Attach to request for use in logging
  (req as any).correlationId = correlationId;
  
  // Add to response headers
  res.setHeader('X-Correlation-ID', correlationId);
  
  next();
}