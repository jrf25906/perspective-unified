import { Request, Response, NextFunction } from 'express';
import express from 'express';
import { NetworkDiagnosticService } from '../services/NetworkDiagnosticService';

/**
 * Event-based network diagnostic middleware - NO method overriding to prevent conflicts
 * Uses Express events to track network issues without interfering with other middleware
 */
export function networkDiagnosticMiddleware() {
  return (req: Request, res: Response, next: NextFunction) => {
    const startTime = Date.now();
    
    // Flag to track if response was sent
    let responseSent = false;
    let responseError: Error | undefined;
    
    // Use event-based approach - listen for response completion
    res.on('finish', () => {
      const duration = Date.now() - startTime;
      responseSent = true;
      
      // Check if this was an error response
      if (res.statusCode >= 400) {
        // Create a simple error object with just the status code
        // Avoid passing response body to prevent recursive logging
        responseError = new Error(`HTTP ${res.statusCode}`);
        // Ensure the error doesn't contain the response body
        responseError.name = 'HTTPError';
        NetworkDiagnosticService.logConnectionAttempt(req, false, responseError);
      } else {
        NetworkDiagnosticService.logConnectionAttempt(req, true);
      }
    });
    
    // Handle request errors
    req.on('error', (error: Error) => {
      if (!responseSent) {
        NetworkDiagnosticService.logConnectionAttempt(req, false, error);
      }
    });
    
    // Handle response errors
    res.on('error', (error: Error) => {
      if (!responseSent) {
        NetworkDiagnosticService.logConnectionAttempt(req, false, error);
      }
    });
    
    // Handle timeout
    res.on('timeout', () => {
      if (!responseSent) {
        const timeoutError = new Error('Request timeout');
        NetworkDiagnosticService.logConnectionAttempt(req, false, timeoutError);
      }
    });
    
    next();
  };
}

/**
 * Middleware to check for CORS violations
 */
export function corsViolationMiddleware() {
  return (req: Request, res: Response, next: NextFunction) => {
    const origin = req.headers.origin || req.headers.referer;
    
    if (origin) {
      // Check if origin is allowed (this will be checked by CORS middleware too)
      // We're just logging violations for diagnostics
      const allowedOriginsHeader = res.getHeader('Access-Control-Allow-Origin');
      const allowedOrigins = typeof allowedOriginsHeader === 'string' || Array.isArray(allowedOriginsHeader) 
        ? allowedOriginsHeader 
        : String(allowedOriginsHeader);
      
      if (allowedOrigins && !isOriginAllowed(origin, allowedOrigins)) {
        NetworkDiagnosticService.logCorsViolation(req, origin);
      }
    }
    
    next();
  };
}

/**
 * Check if origin is allowed based on CORS configuration
 */
function isOriginAllowed(origin: string, allowedOrigins: string | string[]): boolean {
  if (allowedOrigins === '*') return true;
  
  if (typeof allowedOrigins === 'string') {
    return origin === allowedOrigins;
  }
  
  if (Array.isArray(allowedOrigins)) {
    return allowedOrigins.includes(origin);
  }
  
  return false;
} 