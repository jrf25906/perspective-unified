# Deployment Configuration

This directory contains deployment-related configuration files for the Perspective app.

## Files

### Railway Configuration
- **`correct-railway-config.json`** - Verified Railway deployment configuration
- **`railway-mcp-config.json`** - Railway MCP (Model Context Protocol) configuration

### Current Deployment ✅

**Production URL**: `https://backend-production-d218.up.railway.app/api/v1`  
**Status**: **LIVE** (Last deployed: June 26, 2025)  
**Health Check**: `https://backend-production-d218.up.railway.app/health` ✅

## Railway Deployment Commands

```bash
# Login to Railway
railway login

# Link to existing project
railway link backend-production-d218

# Deploy current backend
cd ../backend
railway up
```

## Environment Variables

Make sure these are set in Railway dashboard:
- `NODE_ENV=production`
- `DATABASE_URL` (PostgreSQL connection string)
- `JWT_SECRET` (production secret)
- `JWT_REFRESH_SECRET` (production refresh secret)
- `CORS_ORIGIN` (allowed origins)

## Notes

The backend API uses `/api/v1/` prefix to match iOS app expectations. Ensure all production deployments maintain this route structure.