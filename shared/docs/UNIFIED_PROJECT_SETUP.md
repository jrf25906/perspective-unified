# Perspective Unified - Project Setup Guide

## Overview

Perspective is a unified fullstack application for bias assessment and perspective awareness. This repository contains both the backend API (Node.js/TypeScript) and iOS app (Swift/SwiftUI) in a single, organized structure.

## Project Structure

```
perspective-unified/
├── backend/                    # Node.js/TypeScript API server
│   ├── src/                   # TypeScript source files
│   ├── migrations/            # Database migrations
│   ├── seeds/                 # Database seed files
│   └── package.json          
├── ios/                       # iOS SwiftUI application
│   ├── perspective/           # iOS app source code
│   └── perspective.xcodeproj/ # Xcode project file
├── shared/                    # Shared resources and documentation
│   ├── assets/               # Icons, videos, brand assets
│   ├── docs/                 # Project documentation
│   └── scripts/              # Shared build scripts
├── deployment/               # Deployment configurations
├── build-tools/             # Build automation
└── testing/                 # Integration test scripts
```

## Quick Start

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** or **yarn**
- **Xcode** 15+ (for iOS development)
- **macOS** (for iOS development)

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/jrf25906/perspective-unified.git
cd perspective-unified

# Install backend dependencies
cd backend
npm install

# Run database migrations
npm run migrate

# (Optional) Seed with test data
npm run seed

# Start the development server
npm run dev
```

The backend will start on `http://localhost:3000`

### 2. iOS Development

```bash
# Open the iOS project in Xcode
open ios/perspective.xcodeproj
```

### 3. Build and Run

1. Select a simulator in Xcode
2. Press Cmd+R or click the Run button
3. The app will connect to your local backend

## API Endpoints

The backend provides these endpoints (all prefixed with `/api/v1/`):

- **Authentication**: `/auth/register`, `/auth/login`, `/auth/google`, `/auth/me`
- **Challenges**: `/challenge/today`, `/challenge/submit`, `/challenge/stats`
- **Profile**: `/profile/:id`, `/profile/update`, `/profile/avatar`
- **Echo Score**: `/echo-score/current`, `/echo-score/history`
- **Content**: `/content/featured`, `/content/categories`

## Environment Configuration

### Backend Environment
Create `backend/.env`:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=sqlite://./dev.sqlite3
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key
```

### iOS Configuration
Configuration in `ios/perspective/Core/AppEnvironment.swift`:
- Development: `http://localhost:3000/api/v1`
- Production: Railway deployment URL

## Development Workflow

### Backend Development
```bash
cd backend
npm run dev          # Start development server
npm run test         # Run tests
npm run migrate      # Run database migrations
npm run seed         # Seed test data
```

### iOS Development
- Use Xcode for development
- Hot reload available in simulator
- Check console logs for debugging

### Full Stack Testing
```bash
# Test authentication flow
cd testing
./test-auth-endpoints.js

# Test database connection
node test-db-connection.js
```

## Deployment

### Backend (Railway)
```bash
# Deploy to Railway
railway up

# Configure environment variables via Railway dashboard
```

### iOS (App Store)
- Build release version in Xcode
- Archive and upload to App Store Connect

## Common Issues

### Backend Issues
- **Port 3000 in use**: Change PORT in `.env` or stop other services
- **Database errors**: Delete `dev.sqlite3` and run `npm run migrate`
- **Node version**: Ensure Node.js >= 18.0.0

### iOS Issues
- **Can't connect to backend**: Ensure backend is running on localhost:3000
- **Build errors**: Clean build folder (Cmd+Shift+K) and rebuild
- **Simulator issues**: Reset simulator content and settings

### Integration Issues
- **API authentication**: Check JWT tokens in network requests
- **CORS errors**: Verify CORS configuration in backend
- **Network connectivity**: Use iOS simulator (not physical device for localhost)

## Project Features

### Backend Capabilities
- User authentication with JWT
- Daily challenge system
- Echo score calculation
- Content management
- File upload (avatars)
- SQLite database with migrations

### iOS App Features
- Material 3 design system
- Offline support with caching
- Real-time sync with backend
- Bias assessment challenges
- User profile management
- SwiftUI modern interface

## Scripts and Automation

### Backend Scripts
```bash
npm run dev          # Development server
npm run build        # Build TypeScript
npm run test         # Run tests
npm run migrate      # Database migrations
npm run seed         # Seed data
```

### iOS Scripts
```bash
# Build and test iOS app
cd ios
./test_app.sh        # Automated testing script
./clean-build.sh     # Clean build artifacts
```

## Documentation

- **API Documentation**: `shared/docs/api/`
- **Architecture**: `shared/docs/architecture/`
- **Deployment**: `shared/docs/deployment/`
- **Brand Guidelines**: `shared/docs/brand/`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## Support

For issues and questions:
- Check backend logs in terminal
- Check iOS logs in Xcode console
- Review documentation in `shared/docs/`
- Test with provided scripts in `testing/`

## Next Steps

1. **Development**: Start building features in both backend and iOS
2. **Testing**: Use comprehensive test scripts
3. **Deployment**: Deploy backend to Railway, submit iOS to App Store
4. **Monitoring**: Set up logging and analytics