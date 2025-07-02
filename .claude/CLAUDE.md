# Perspective App - Unified Project - Claude Memory

## Project Overview
Multi-platform training application designed to help users escape echo chambers and build cognitive flexibility through news exposure, interactive reasoning drills, and a personalized "Echo Score" coaching system.

**Project Location**: `/Users/jamesfarmer/perspective-unified/`

## Architecture
- **Backend**: Node.js/Express.js with TypeScript (`/backend/`)
- **iOS**: Native SwiftUI app (`/ios/`) - Clean architecture using SPM
- **Database**: PostgreSQL (production), SQLite (development)
- **Shared**: Assets and documentation (`/shared/`)

## Development Commands

### Backend Commands
- `npm run dev` - Start development server with hot reload (port 3000)
- `npm run build` - Compile TypeScript
- `npm run test` - Run Jest tests
- `npm run lint` - Run ESLint
- `npm run typecheck` - TypeScript type checking
- `npm run migrate` - Run database migrations
- `npm run seed` - Seed database with test data

### iOS Commands
- Open `ios/perspective.xcodeproj` in Xcode
- Build and run using Xcode (Cmd+R)
- Uses Swift Package Manager (SPM) for dependencies

## API Configuration
- **Development**: `http://localhost:3000/api/v1`
- **Production**: `https://backend-production-d218.up.railway.app/api/v1`
- **Routes updated**: All backend routes use `/api/v1/` prefix to match iOS expectations

## Project Consolidation Notes
This unified project was created by combining:
- **Full Backend**: From `/Users/jamesfarmer/perspective-app/backend/` (comprehensive API)
- **Clean iOS App**: From `/Users/jamesfarmer/Desktop/perspective/` (modern SwiftUI architecture)
- **Shared Assets**: Consolidated from various locations

## Backend Technical Details
- **Framework**: Express.js with TypeScript
- **Database ORM**: Knex.js for migrations and queries
- **Authentication**: JWT tokens with Google OAuth
- **Security**: Helmet.js, CORS, rate limiting
- **Environment**: Node.js ≥18.0.0, npm ≥8.0.0

## iOS Technical Details
- **Architecture**: SwiftUI with clean MVVM pattern
- **Dependencies**: Swift Package Manager (no CocoaPods)
- **Target**: iOS 15.0+
- **Configuration**: Environment-based API endpoints

## Key Features
- Daily Challenge System with rotating challenge types
- Echo Score 2.0 multi-factor cognitive flexibility tracking
- News ingestion from multiple sources with bias ratings
- Offline functionality and background sync
- Content moderation pipeline

## File Organization
- `/backend/` - TypeScript backend source (migrated from perspective-app)
- `/ios/` - iOS SwiftUI application (migrated from Desktop/perspective)
- `/shared/assets/` - Common assets (icons, videos, brand elements)
- `/shared/docs/` - Project documentation
- `/shared/scripts/` - Build and utility scripts

## Railway Deployment ✅
- **Project Name**: `perspective-backend`
- **Production URL**: `https://backend-production-d218.up.railway.app`
- **API Base**: `https://backend-production-d218.up.railway.app/api/v1`
- **Status**: **DEPLOYED AND RUNNING** (June 26, 2025)
- **Commands**: 
  - `railway login`
  - `railway link` (select perspective-backend)
  - `railway up` (from backend directory)
- **Environment Variables Set**: NODE_ENV, JWT secrets, CORS
- **Pending**: PostgreSQL database (add via Railway dashboard)

## Environment Variables
- Check `.env.example` in backend directory
- Database connection, JWT secrets, OAuth keys required
- Different configs for development/production environments

## Backup Information
- Original projects backed up to: `/Users/jamesfarmer/perspective-backup-20250626/`
- Safe to reference if needed during transition

## Connection Points Updated
- Backend routes: `/api/` → `/api/v1/` (in routes.setup.ts) ✅
- iOS development URL: port 5000 → 3000 (in AppEnvironment.swift) ✅
- Asset paths: Consolidated to shared/assets/ ✅
- Package.json start script: Fixed to use dist/server.js ✅
- Railway deployment: Root directory issue resolved ✅

## Recent Fixes (June 26, 2025)
- Fixed TypeScript compilation error in echoScoreScheduler.ts
- Updated package.json start script to use correct entry point
- Removed "backend" root directory setting in Railway
- Created nixpacks.toml and railway.json for proper deployment
- Successfully deployed to Railway with /api/v1 routes working