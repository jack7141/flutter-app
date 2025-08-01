#!/bin/bash

echo "🚀 Starting TestFlight build process for Celeb Voice..."

# Get version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo "📦 Detected version: $VERSION"

# Get bundle ID from iOS project
BUNDLE_ID=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*PRODUCT_BUNDLE_IDENTIFIER = //' | sed 's/;//')
echo "🎯 Detected bundle ID: $BUNDLE_ID"

# Get app display name from iOS Info.plist
APP_NAME=$(grep -A1 "CFBundleDisplayName" ios/Runner/Info.plist | tail -1 | sed 's/.*<string>//' | sed 's/<\/string>//')
echo "📱 App name: $APP_NAME"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Update iOS pods
echo "🍎 Updating iOS pods..."
cd ios
pod install
cd ..

# Build iOS for TestFlight
echo "📱 Building iOS for TestFlight..."
flutter build ios --release --no-codesign

echo "✅ Build completed successfully!"
echo ""
echo "🎯 Bundle ID: $BUNDLE_ID"
echo "📱 App Name: $APP_NAME"
echo "🔢 Version: $VERSION" 