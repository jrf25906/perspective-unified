# Perspective App - Unified Project

> Multi-platform training application designed to help users escape echo chambers and build cognitive flexibility through news exposure, interactive reasoning drills, and a personalized "Echo Score" coaching system.

## 🏗️ Project Structure

```
perspective-unified/
├── backend/              # Full-featured Node.js/Express API
├── ios/                  # Clean SwiftUI iOS application
├── shared/               # Shared assets and documentation
│   ├── assets/          # Icons, videos, brand assets
│   ├── docs/            # Project documentation
│   └── scripts/         # Build and utility scripts
└── .claude/             # Claude Code configuration
```

## 🚀 Quick Start

### Backend Development
```bash
cd backend
npm install
npm run migrate
npm run dev
```

### iOS Development
```bash
open ios/perspective.xcodeproj
# Build and run in Xcode
```

## 📱 Platforms

- **Backend**: Node.js/Express.js with TypeScript
- **iOS**: Native SwiftUI application
- **Database**: PostgreSQL (production), SQLite (development)

## 🛠️ Development Commands

### Backend
- `npm run dev` - Start development server
- `npm run build` - Compile TypeScript
- `npm run test` - Run tests
- `npm run migrate` - Run database migrations
- `npm run seed` - Seed database with test data

### iOS
- Build and run through Xcode
- Uses Swift Package Manager (SPM) for dependencies

## 🌐 API Configuration

### Development
- Backend: `http://localhost:3000`
- iOS connects to: `http://localhost:3000/api/v1`

### Production (Live on Railway ✅)
- Backend: `https://backend-production-d218.up.railway.app`
- iOS connects to: `https://backend-production-d218.up.railway.app/api/v1`
- Status: **Deployed and Running** (Last updated: June 26, 2025)

## 📚 Documentation

- **Architecture**: `shared/docs/architecture/`
- **API Docs**: `shared/docs/api/`
- **iOS Development**: `shared/docs/ios/`
- **Deployment**: `shared/docs/deployment/`

## 🔧 Environment Setup

1. **Node.js**: ≥18.0.0
2. **Xcode**: Latest version with iOS SDK
3. **Database**: PostgreSQL for production, SQLite for development

## 📦 Key Features

- Daily Challenge System with rotating challenge types
- Echo Score 2.0 multi-factor cognitive flexibility tracking
- News ingestion from multiple sources with bias ratings
- Offline functionality and background sync
- Content moderation pipeline

## 🚢 Deployment

### Backend (Railway) ✅
**Current Status**: Deployed and running at `https://backend-production-d218.up.railway.app`

To deploy updates:
```bash
cd backend
railway up
```

**Note**: Database (PostgreSQL) needs to be added via Railway dashboard for full production functionality.

### iOS (App Store)
- Archive and upload through Xcode
- Configure signing and provisioning profiles
- Production API URL is pre-configured

## 🤝 Contributing

1. Follow existing code conventions
2. Run tests before committing
3. Update documentation for new features
4. Use descriptive commit messages

## 📄 License

Proprietary - All rights reserved

---

**Note**: This is a consolidated project combining the full-featured backend from the original `perspective-app` with the clean iOS architecture from the refactored project.