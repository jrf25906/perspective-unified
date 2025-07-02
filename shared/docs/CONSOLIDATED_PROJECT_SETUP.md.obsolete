# Perspective App - Consolidated Project Setup

## Overview

You have two versions of the Perspective app:

1. **Full Project** (`~/perspective-app/`): Contains the complete backend and original iOS app with architectural issues
2. **Clean iOS Project** (`~/Desktop/perspective/`): A refactored iOS app with clean architecture but minimal backend

This guide explains how to use them together.

## Project Structure

```
~/perspective-app/               # Main project directory
├── backend/                     # Full-featured backend (USE THIS)
│   ├── src/                     # TypeScript source files
│   ├── migrations/              # Database migrations
│   └── package.json            
├── ios/                        # Original iOS app (DON'T USE - has architecture issues)
└── android/                    # Android app

~/Desktop/perspective/          # Clean iOS project directory
├── perspective/                # iOS app source (USE THIS)
├── perspective.xcodeproj/      # Xcode project file
└── backend/                    # Minimal mock backend (DON'T USE)
```

## What Changed

### 1. Backend API Routes
- Updated from `/api/` to `/api/v1/` to match iOS expectations
- File modified: `~/perspective-app/backend/src/setup/routes.setup.ts`

### 2. iOS Development URL
- Changed from `http://localhost:5000/api/v1` to `http://localhost:3000/api/v1`
- File modified: `~/Desktop/perspective/perspective/Core/AppEnvironment.swift`

## Quick Start

### 1. Start the Backend

```bash
# Navigate to the full backend
cd ~/perspective-app/backend

# Install dependencies (if not already done)
npm install

# Run database migrations
npm run migrate

# (Optional) Seed with test data
npm run seed

# Start the development server
npm run dev
```

The backend will start on `http://localhost:3000`

### 2. Open the iOS Project

```bash
# Open the clean iOS project in Xcode
open ~/Desktop/perspective/perspective.xcodeproj
```

### 3. Build and Run
1. Select a simulator in Xcode
2. Press Cmd+R or click the Run button
3. The app should connect to your local backend

## API Endpoints

The full backend provides these endpoints (all prefixed with `/api/v1/`):

- **Authentication**: `/auth/register`, `/auth/login`, `/auth/google`, `/auth/me`
- **Challenges**: `/challenge/today`, `/challenge/submit`, `/challenge/stats`
- **Profile**: `/profile/:id`, `/profile/update`, `/profile/avatar`
- **Echo Score**: `/echo-score/current`, `/echo-score/history`
- **Content**: `/content/featured`, `/content/categories`

## Environment Configuration

### Backend (.env)
Located at `~/perspective-app/backend/.env`:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL=sqlite://./dev.sqlite3
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key
```

### iOS App
Configuration in `~/Desktop/perspective/perspective/Core/AppEnvironment.swift`:
- Development: `http://localhost:3000/api/v1`
- Staging/Production: `https://backend-production-d218.up.railway.app/api/v1`

## Common Issues

### Backend won't start
- Check Node.js version: `node --version` (needs >= 18.0.0)
- Delete `node_modules` and run `npm install` again
- Check if port 3000 is already in use

### iOS app can't connect to backend
- Ensure backend is running: `npm run dev`
- Check console logs in Xcode for connection errors
- Verify the simulator can access localhost (not an issue on macOS)

### Database errors
- Run migrations: `npm run migrate`
- For SQLite issues, delete `dev.sqlite3` and run migrations again

## Development Workflow

1. **Backend Changes**: Edit files in `~/perspective-app/backend/`
2. **iOS Changes**: Edit files in `~/Desktop/perspective/`
3. **Testing**: Always test API changes with the iOS app
4. **Version Control**: Commit changes in both repositories

## Next Steps

1. **Testing**: Verify the iOS app can authenticate and fetch data
2. **Feature Development**: Add new features to both backend and iOS
3. **Production**: Deploy backend to Railway, update iOS production URL

## Scripts

A setup script is available at `~/perspective-app/setup-consolidated.sh` to automate the backend setup process.

## Support

For issues:
- Backend logs: Check terminal running `npm run dev`
- iOS logs: Check Xcode console
- Network issues: Use the network diagnostic endpoint (dev only)