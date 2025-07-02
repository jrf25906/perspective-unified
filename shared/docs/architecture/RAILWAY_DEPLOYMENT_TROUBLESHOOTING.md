# Railway Deployment Troubleshooting

## Current Issue: API Routes Missing (July 2, 2025)

### Problem Description
The Railway deployment at `https://backend-production-d218.up.railway.app` is missing API routes:
- ❌ `/api/v1/auth/me` → 404 "Cannot GET /api/v1/auth/me"
- ❌ `/api/v1/challenge/today` → 404 "Cannot GET /api/v1/challenge/today"
- ✅ `/health` → Returns simple `{"status":"ok"}` instead of detailed response
- ✅ POST `/api/v1/auth/login` → Works correctly

### Root Cause Analysis
The Railway deployment appears to be using an **outdated version** of the backend codebase, likely from before the repository unification.

**Evidence:**
1. **Local Backend**: Returns detailed health response with version, uptime, memory usage
2. **Deployed Backend**: Returns simple `{"status":"ok"}` response
3. **Missing Routes**: Auth and challenge endpoints return HTML 404 pages
4. **Route Setup Logs**: Local shows route mounting logs, deployed version doesn't

### Technical Investigation

#### Local Backend (Working)
```bash
cd backend && npm run dev
# Output shows:
# 📍 Mounting auth routes at /api/v1/auth
# 📍 Mounting challenge routes at /api/v1/challenge
# ✅ All API routes set up successfully
```

#### Deployed Backend (Problematic)
```bash
curl https://backend-production-d218.up.railway.app/health
# Returns: {"status":"ok"}
# Should return detailed info like local version
```

### Attempted Solutions

1. **Manual Deployment**: `railway up` - Did not resolve
2. **Force Redeploy**: `railway redeploy` - Did not resolve  
3. **Build Verification**: Local `npm run build` works correctly
4. **Code Review**: All routes properly defined in TypeScript source

### Current Workaround

**For iOS Development:**
Temporarily modified `ios/perspective/Core/Environment.swift` to use local backend:

```swift
// TEMPORARY: Using local backend due to Railway deployment issue
static let apiBaseURL = "http://localhost:3000/api/v1"
```

**Steps to use workaround:**
1. Start local backend: `cd backend && npm run dev`
2. Ensure iOS simulator can access localhost (should work on macOS)
3. Build and run iOS app in Xcode
4. All API endpoints should work correctly

### Potential Root Causes

1. **Repository Configuration**: Railway may still be connected to old split repository
2. **Branch Configuration**: Deployment may be pulling from wrong branch
3. **Build Cache**: Railway build cache may be stale
4. **Environment Variables**: Missing environment variables causing route setup failure

### Recommended Resolution Steps

1. **Verify Railway Repository Connection**
   - Check Railway dashboard project settings
   - Ensure connection to `jrf25906/perspective-unified` repository
   - Verify branch is set to `main`

2. **Clear Railway Build Cache**
   - Delete and recreate Railway service if necessary
   - Force fresh deployment from unified repository

3. **Alternative: Create New Railway Service**
   - Create fresh Railway service connected to unified repository
   - Update DNS/URL references after successful deployment

### Immediate Actions for Development

**Backend Development:**
- Use local backend for all development and testing
- Local backend has all routes and features working correctly

**iOS Development:**  
- Use localhost configuration (already implemented)
- All features should work normally with local backend

**Testing:**
- Integration tests should run against local backend
- Update CI/CD to use local backend until Railway issue resolved

### Railway Configuration Files

All Railway configuration files are correct:

**railway.json:**
```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "npm run build"
  },
  "deploy": {
    "startCommand": "npm start"
  }
}
```

**nixpacks.toml:**
```toml
[variables]
NODE_ENV = "production"

[phases.build]
cmds = ["npm run build"]

[start]
cmd = "npm start"
```

### Monitoring

To verify when the issue is resolved:

```bash
# Test auth endpoint
curl https://backend-production-d218.up.railway.app/api/v1/auth/test

# Should return validation error (not 404):
# {"error":{"code":"RESPONSE_VALIDATION_ERROR",...}}

# Test health endpoint  
curl https://backend-production-d218.up.railway.app/health

# Should return detailed response with version, uptime, memory
```

### Resolution Confirmation

When Railway deployment is fixed:

1. **Update iOS Configuration**: Revert `Environment.swift` to use Railway URL
2. **Test All Endpoints**: Verify auth, challenge, profile endpoints work
3. **Update Documentation**: Mark this issue as resolved
4. **Remove Workaround**: Delete temporary localhost configuration

### Related Files

- `ios/perspective/Core/Environment.swift` - iOS API configuration
- `backend/src/setup/routes.setup.ts` - Route configuration  
- `backend/railway.json` - Railway deployment config
- `backend/nixpacks.toml` - Nixpacks build config

---

**Last Updated**: July 2, 2025  
**Status**: Active Issue - Workaround in Place  
**Priority**: High - Affects production deployment