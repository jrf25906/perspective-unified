# Railway Deployment Guide

## Current Deployment Status ✅

**Production URL**: `https://backend-production-d218.up.railway.app`  
**API Base**: `https://backend-production-d218.up.railway.app/api/v1`  
**Status**: Live and Running (as of June 26, 2025)

## Quick Deploy Commands

```bash
cd /Users/jamesfarmer/perspective-unified/backend
railway up
```

## Project Configuration

### Railway Project Details
- **Project Name**: perspective-backend
- **Service Name**: backend
- **Environment**: production
- **Builder**: Nixpacks
- **Port**: 8080 (Railway assigned)

### Environment Variables (Currently Set)
- `NODE_ENV`: production
- `JWT_SECRET`: perspective-app-jwt-secret-production-key-2025
- `JWT_REFRESH_SECRET`: perspective-app-jwt-refresh-secret-production-key-2025
- `CORS_ORIGIN`: https://backend-production-d218.up.railway.app,http://localhost:3000

### Required but Not Yet Set
- `DATABASE_URL`: PostgreSQL connection string (add via Railway dashboard)

## Deployment Process

### 1. Initial Setup (Already Completed ✅)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Link to project
cd backend
railway link
# Select: perspective-backend
```

### 2. Deploy Updates
```bash
# From backend directory
railway up
```

### 3. Check Deployment Status
```bash
# View logs
railway logs

# Check build logs
railway logs -b

# Check project status
railway status
```

## Important Configuration Files

### nixpacks.toml
```toml
[variables]
NODE_ENV = "production"

[phases.install]
cmds = ["npm ci"]

[phases.build]
cmds = ["npm run build"]

[start]
cmd = "npm start"
```

### railway.json
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm run start",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### .railwayignore
```
node_modules/
dist/
.env
.env.*
*.log
logs/
uploads/
dev.sqlite3
test-*.js
.DS_Store
*.md
docs/
migrations/
seeds/
tests/
coverage/
```

## API Routes

All routes use the `/api/v1` prefix:

- **Health Check**: GET `/health`
- **Authentication**: 
  - POST `/api/v1/auth/login`
  - POST `/api/v1/auth/register`
  - GET `/api/v1/auth/me`
- **Challenges**: 
  - GET `/api/v1/challenge/today`
  - POST `/api/v1/challenge/submit`
- **Profile**: 
  - GET `/api/v1/profile/:id`
  - PUT `/api/v1/profile/update`
- **Echo Score**: 
  - GET `/api/v1/echo-score/current`
  - GET `/api/v1/echo-score/history`

## Database Setup (Required for Production)

The backend is currently running with mock data. To enable full functionality:

1. **Add PostgreSQL to Railway**:
   - Go to [Railway Dashboard](https://railway.app)
   - Navigate to your project
   - Click "New" → "Database" → "Add PostgreSQL"
   - Railway will automatically set `DATABASE_URL`

2. **Run Migrations** (automatic on next deploy):
   - Migrations will run automatically when `DATABASE_URL` is detected
   - Located in `backend/migrations/`

## Troubleshooting

### Common Issues

1. **"Cannot find root directory: backend"**
   - Solution: Ensure Root Directory is empty in Railway settings
   - Deploy from `/Users/jamesfarmer/perspective-unified/backend`

2. **Routes returning 404**
   - Check that routes use `/api/v1` prefix
   - Verify deployment completed successfully
   - Check `railway logs` for errors

3. **Database connection errors**
   - Add PostgreSQL via Railway dashboard
   - Ensure `DATABASE_URL` is set in environment variables

### Useful Commands

```bash
# Check current environment variables
railway variables

# Add new environment variable
railway variables --set KEY=value

# Open Railway dashboard for project
railway open

# Check service status
railway status
```

## iOS App Integration

The iOS app is pre-configured with production URLs:

```swift
// AppEnvironment.swift
struct ProductionConfig: EnvironmentConfigurable {
    let apiBaseURL = "https://backend-production-d218.up.railway.app/api/v1"
    // ...
}
```

No changes needed - just build and run the iOS app!

## Next Steps

1. ✅ Backend deployed and running
2. ⏳ Add PostgreSQL database via Railway dashboard
3. ⏳ Run database migrations
4. ⏳ Test full API functionality with database
5. ⏳ Deploy iOS app to TestFlight/App Store