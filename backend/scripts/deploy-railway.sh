#!/bin/bash

# Railway Deployment Script
# This script handles database migrations and deployment to Railway

echo "🚀 Starting Railway deployment process..."

# Check if we're in production
if [ "$NODE_ENV" = "production" ]; then
    echo "📦 Running in production mode"
    
    # Run database migrations
    echo "🗄️  Running database migrations..."
    npx knex migrate:latest --env production
    
    if [ $? -ne 0 ]; then
        echo "❌ Migration failed!"
        exit 1
    fi
    
    echo "✅ Migrations completed successfully"
else
    echo "⚠️  Not in production mode. Set NODE_ENV=production to run migrations."
fi

echo "🎉 Deployment preparation complete!"