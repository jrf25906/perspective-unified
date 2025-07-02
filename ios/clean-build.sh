#!/bin/bash

# Perspective iOS Project Clean Build Script
# This script resolves common Xcode build issues including GUID conflicts

echo "🧹 Starting comprehensive project cleanup..."

# Step 1: Clean project
echo "1️⃣ Cleaning Xcode project..."
xcodebuild clean -project perspective.xcodeproj -scheme perspective

# Step 2: Remove derived data
echo "2️⃣ Removing derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Step 3: Remove user-specific files
echo "3️⃣ Removing user-specific project files..."
rm -rf perspective.xcodeproj/xcuserdata
rm -rf perspective.xcodeproj/project.xcworkspace/xcuserdata

# Step 4: Handle different cleanup levels
if [ "$1" = "--reset-packages" ]; then
    echo "4️⃣ Resetting Swift Package Manager state..."
    rm -rf perspective.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
elif [ "$1" = "--nuclear" ]; then
    echo "4️⃣ NUCLEAR OPTION: Completely recreating workspace..."
    echo "⚠️  This will fix severe GUID conflicts but takes longer"
    rm -rf perspective.xcodeproj/project.xcworkspace
fi

# Step 5: Re-resolve packages
echo "5️⃣ Re-resolving package dependencies..."
xcodebuild -project perspective.xcodeproj -resolvePackageDependencies

echo "✅ Project cleanup complete!"
echo ""
echo "💡 Usage:"
echo "   ./clean-build.sh                    # Standard cleanup"
echo "   ./clean-build.sh --reset-packages   # Deep cleanup (resets SPM)"
echo "   ./clean-build.sh --nuclear          # Nuclear option (recreates workspace)"
echo ""
echo "🚀 You can now build the project safely!"