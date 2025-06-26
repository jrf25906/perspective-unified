# Deployment Guide

This document covers deployment procedures for the Perspective application.

## Backend Deployment (Railway)

The backend is deployed on Railway and automatically deploys when changes are pushed to the main branch.

### Current Deployment

- **Project**: perspective-backend
- **Service**: backend
- **Production URL**: https://backend-production-d218.up.railway.app
- **API Base URL**: https://backend-production-d218.up.railway.app/api/v1
- **GitHub Repository**: jrf25906/perspective-2

### Automatic Deployment

Railway is configured to automatically deploy the backend when:
1. Changes are pushed to the `main` branch
2. The `backend/` directory contains changes
3. The build completes successfully

### Build Configuration

The deployment uses `nixpacks.toml` configuration:

```toml
[phases.build]
cmd = "npm run build"

[phases.start]
cmd = "npm start"

[variables]
NODE_ENV = "production"
```

### Manual Deployment

If you need to manually trigger a deployment:

1. **Using Railway CLI**:
   ```bash
   railway deploy
   ```

2. **Using Railway Dashboard**:
   - Go to [railway.app](https://railway.app)
   - Select the `perspective-backend` project
   - Select the `backend` service
   - Click "Deploy" to trigger a new deployment

### Environment Variables

The following environment variables are configured in Railway:

- `NODE_ENV`: Set to "production"
- `PORT`: Automatically provided by Railway
- Additional variables can be added through the Railway dashboard

### Monitoring

- **Health Check**: https://backend-production-d218.up.railway.app/health
- **Logs**: Available in the Railway dashboard under the service logs
- **Metrics**: Available in the Railway dashboard

### Troubleshooting

#### Deployment Fails

1. Check the build logs in Railway dashboard
2. Verify `package.json` scripts are correct:
   - `build`: Should compile TypeScript
   - `start`: Should run the compiled application
3. Check for missing dependencies in `package.json`

#### Service Not Responding

1. Check the service logs in Railway dashboard
2. Verify the `PORT` environment variable is being used
3. Check health endpoint: https://backend-production-d218.up.railway.app/health

#### Database Issues

1. Ensure database service is running in Railway
2. Check database connection string in environment variables
3. Verify database migrations have been applied

### Scaling

Railway automatically handles scaling based on traffic. For manual scaling:

1. Go to Railway dashboard
2. Select the service
3. Adjust replica count in service settings

## iOS App Deployment

### Configuration

The iOS app is configured to use the Railway backend:

- **Development**: Uses Railway backend (https://backend-production-d218.up.railway.app/api/v1)
- **Staging**: Uses Railway backend (https://backend-production-d218.up.railway.app/api/v1)  
- **Production**: Uses Railway backend (https://backend-production-d218.up.railway.app/api/v1)

### Build Configurations

The app supports different build configurations:
- `DEBUG`: Development mode, verbose logging
- `STAGING`: Staging mode with production backend
- `RELEASE`: Production mode

### App Store Deployment

1. **Archive the app** in Xcode
2. **Upload to App Store Connect**
3. **Submit for review**

## Rollback Procedures

### Backend Rollback

If a deployment causes issues:

1. **Using Railway Dashboard**:
   - Go to the service deployments page
   - Find the last working deployment
   - Click "Redeploy" on that deployment

2. **Using Git**:
   ```bash
   # Revert to previous commit
   git revert <commit-hash>
   git push origin main
   ```

### iOS App Rollback

1. **App Store**: Use App Store Connect to roll back to previous version
2. **TestFlight**: Deploy previous build to TestFlight

## Security Considerations

### Environment Variables

- Never commit sensitive information to Git
- Use Railway's environment variable management
- Rotate secrets regularly

### API Security

- HTTPS is enforced on Railway
- JWT tokens are used for authentication
- Rate limiting is implemented

### Database Security

- Database is only accessible from Railway services
- Regular backups are maintained
- Connection strings are encrypted

## Backup and Recovery

### Database Backups

Railway automatically creates database backups. For manual backup:

1. Export database from Railway dashboard
2. Store backup in secure location
3. Test restore procedures regularly

### Code Backups

- GitHub serves as primary code repository
- Regular pushes ensure code is backed up
- Tags mark release versions

## Support

For deployment issues:

1. Check Railway dashboard for service status
2. Review logs for error messages
3. Consult this guide for common solutions
4. Contact Railway support if needed

## Update Procedures

### Adding New Environment Variables

1. Add variable in Railway dashboard
2. Update documentation
3. Test with new deployment

### Database Schema Changes

1. Create migration scripts
2. Test migrations locally
3. Deploy and run migrations
4. Verify schema changes

### Dependency Updates

1. Update `package.json`
2. Test locally
3. Deploy and monitor
4. Rollback if issues occur