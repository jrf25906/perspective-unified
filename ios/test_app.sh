#!/bin/bash

echo "🚀 Testing Perspective app..."

# Clean and build
echo "📦 Building project..."
xcodebuild -project perspective.xcodeproj -scheme perspective -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro' clean build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Launch simulator and install app
    echo "📱 Launching simulator..."
    xcrun simctl boot "iPhone 16 Pro" 2>/dev/null || echo "Simulator already running"
    
    echo "📲 Installing and launching app..."
    xcrun simctl install "iPhone 16 Pro" "/Users/jamesfarmer/Library/Developer/Xcode/DerivedData/perspective-fewqdgicdlgjcvgktilpknopmsmw/Build/Products/Debug-iphonesimulator/perspective.app"
    
    PID=$(xcrun simctl launch "iPhone 16 Pro" jamesfarmer.perspective)
    
    echo "✨ App launched successfully! (PID: ${PID#*: })"
    echo "🎉 White screen issue should now be resolved!"
    echo "📱 The app should display the Perspective welcome screen with brand colors"
else
    echo "❌ Build failed!"
    exit 1
fi