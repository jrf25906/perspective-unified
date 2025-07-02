import { Express } from 'express';
import { serverConfig } from '../app-config/server.config';
import authRoutes from '../routes/authRoutes';
import challengeRoutes from '../routes/challengeRoutes';
import profileRoutes from '../routes/profileRoutes';
import adminRoutes from '../routes/adminRoutes';
import contentRoutes from '../routes/contentRoutes';
import echoScoreRoutes from '../routes/echoScoreRoutes';
import networkDiagnosticRoutes from '../routes/networkDiagnosticRoutes';
import errorHandler from '../middleware/errorHandler';

export function setupHealthCheck(app: Express): void {
  app.get('/health', async (req, res) => {
    res.status(200).json({ 
      status: 'OK',
      timestamp: new Date().toISOString(),
      version: serverConfig.version,
      environment: serverConfig.environment,
      uptime: process.uptime(),
      memory: process.memoryUsage()
    });
  });
}

export function setupAPIRoutes(app: Express): void {
  console.log('🔧 Setting up API routes...');
  
  try {
    // Main API routes with v1 prefix to match iOS app expectations
    console.log('📍 Mounting auth routes at /api/v1/auth');
    app.use('/api/v1/auth', authRoutes);
    
    console.log('📍 Mounting challenge routes at /api/v1/challenge');
    app.use('/api/v1/challenge', challengeRoutes);
    
    console.log('📍 Mounting profile routes at /api/v1/profile');
    app.use('/api/v1/profile', profileRoutes);
    
    console.log('📍 Mounting admin routes at /api/v1/admin');
    app.use('/api/v1/admin', adminRoutes);
    
    console.log('📍 Mounting content routes at /api/v1/content');
    app.use('/api/v1/content', contentRoutes);
    
    console.log('📍 Mounting echo-score routes at /api/v1/echo-score');
    app.use('/api/v1/echo-score', echoScoreRoutes);
    
    // Diagnostic routes (development only)
    if (serverConfig.environment === 'development') {
      console.log('📍 Mounting diagnostic routes at /api/v1/diagnostics/network');
      app.use('/api/v1/diagnostics/network', networkDiagnosticRoutes);
    }
    
    console.log('✅ All API routes set up successfully');
  } catch (error) {
    console.error('❌ Error setting up API routes:', error);
    throw error;
  }
}

export function setup404Handler(app: Express): void {
  app.use('*', (req, res) => {
    res.status(404).json({ 
      error: {
        code: 'NOT_FOUND',
        message: 'Route not found',
        path: req.originalUrl,
        method: req.method,
        timestamp: new Date().toISOString()
      }
    });
  });
}

export function setupErrorHandler(app: Express): void {
  app.use(errorHandler);
}

export function setupAllRoutes(app: Express): void {
  setupHealthCheck(app);
  setupAPIRoutes(app);
  setup404Handler(app);
  setupErrorHandler(app);
} 