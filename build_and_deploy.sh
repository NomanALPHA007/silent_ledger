#!/bin/bash

# Silent Ledger Deployment Script
echo "🚀 Silent Ledger Deployment Script"
echo "=================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if environment variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Environment variables SUPABASE_URL and SUPABASE_ANON_KEY must be set."
    echo "Please run:"
    echo "export SUPABASE_URL=your_supabase_url"
    echo "export SUPABASE_ANON_KEY=your_supabase_anon_key"
    exit 1
fi

echo "✅ Environment variables are set"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Please fix them before deploying."
    exit 1
fi

echo "✅ All tests passed"

# Build for web
echo "🌐 Building for web..."
flutter build web --release \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
    --web-renderer canvaskit

if [ $? -ne 0 ]; then
    echo "❌ Web build failed."
    exit 1
fi

echo "✅ Web build completed successfully"

# Build for Android (optional)
read -p "🤖 Do you want to build for Android? (y/N): " build_android
if [[ $build_android =~ ^[Yy]$ ]]; then
    echo "🤖 Building for Android..."
    flutter build appbundle --release \
        --dart-define=SUPABASE_URL=$SUPABASE_URL \
        --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
    
    if [ $? -eq 0 ]; then
        echo "✅ Android build completed: build/app/outputs/bundle/release/app-release.aab"
    else
        echo "❌ Android build failed"
    fi
fi

# Build for iOS (optional, macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "🍎 Do you want to build for iOS? (y/N): " build_ios
    if [[ $build_ios =~ ^[Yy]$ ]]; then
        echo "🍎 Building for iOS..."
        flutter build ios --release \
            --dart-define=SUPABASE_URL=$SUPABASE_URL \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
        
        if [ $? -eq 0 ]; then
            echo "✅ iOS build completed"
        else
            echo "❌ iOS build failed"
        fi
    fi
fi

echo ""
echo "🎉 Build process completed!"
echo "📁 Web build is ready in: build/web/"
echo ""
echo "📋 Next steps for deployment:"
echo "1. For Vercel: Push to GitHub (auto-deployment) or upload build/web/"
echo "2. For Android: Upload build/app/outputs/bundle/release/app-release.aab to Google Play Console"
echo "3. For iOS: Open build/ios/Runner.xcworkspace in Xcode and archive for App Store"
echo ""
echo "🔗 Don't forget to set up environment variables in your deployment platform!"