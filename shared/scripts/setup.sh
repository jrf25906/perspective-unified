#!/bin/bash

# Perspective Unified Project - Setup Script
echo "🚀 Perspective Unified Project Setup"
echo "====================================="

# Check if we're in the right directory
if [ ! -f "backend/package.json" ]; then
    echo "❌ Error: This script must be run from the perspective-unified root directory"
    echo "   Current directory: $(pwd)"
    echo "   Please run: cd /Users/jamesfarmer/perspective-unified"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo ""
echo "📋 Checking prerequisites..."

if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js >= 18.0.0"
    exit 1
fi

if ! command_exists npm; then
    echo "❌ npm is not installed. Please install npm >= 8.0.0"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"

# Setup backend
echo ""
echo "🔧 Setting up backend..."
cd backend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing backend dependencies..."
    npm install
else
    echo "✅ Backend dependencies already installed"
fi

# Check for .env file
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📝 Creating .env file from .env.example..."
        cp .env.example .env
        echo "⚠️  Please edit backend/.env with your configuration"
    else
        echo "⚠️  No .env file found. Creating basic .env..."
        cat > .env << EOF
NODE_ENV=development
PORT=3000
DATABASE_URL=sqlite://./dev.sqlite3
JWT_SECRET=your-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-key-here
CORS_ORIGIN=http://localhost:3000,http://localhost:8081
EOF
    fi
fi

# Run migrations
echo ""
echo "🗄️  Running database migrations..."
npm run migrate

# Optionally seed the database
read -p "Do you want to seed the database with test data? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm run seed
fi

# Build TypeScript
echo ""
echo "🔨 Building TypeScript..."
npm run build

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To start development:"
echo "========================="
echo "1. Start the backend server:"
echo "   cd backend && npm run dev"
echo ""
echo "2. Open the iOS project in Xcode:"
echo "   open ios/perspective.xcodeproj"
echo ""
echo "3. Build and run the iOS app in the simulator"
echo ""
echo "📁 Project structure:"
echo "- Backend: /backend/ (full-featured API)"
echo "- iOS: /ios/ (clean SwiftUI architecture)"
echo "- Assets: /shared/assets/ (icons, videos, brand)"
echo "- Docs: /shared/docs/ (project documentation)"
echo ""