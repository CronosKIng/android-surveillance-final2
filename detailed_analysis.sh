#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 DETAILED ANALYSIS - NINI KINASABABISHA SHIDA?"
echo "================================================"

echo ""
echo "1. 📱 APP MODULE CHECK:"
if [ -d "app/src/main/java/com/security/update" ]; then
    echo "✅ Java source files exist"
    ls -la app/src/main/java/com/security/update/
else
    echo "❌ Java source files missing!"
    mkdir -p app/src/main/java/com/security/update
fi

echo ""
echo "2. 🔧 GRADLE SETUP CHECK:"
if [ -f "gradlew" ]; then
    echo "✅ Gradle wrapper exists"
    ./gradlew --version || echo "❌ Gradle wrapper not executable"
else
    echo "❌ Gradle wrapper missing!"
fi

echo ""
echo "3. 📄 ANDROID MANIFEST CHECK:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest exists"
    grep -o '<activity\|<service\|<receiver' app/src/main/AndroidManifest.xml | wc -l | xargs echo "📋 Components found:"
else
    echo "❌ AndroidManifest missing!"
fi

echo ""
echo "4. 🏗️  BUILD OUTPUT CHECK:"
echo "📁 Build directories:"
ls -la app/build/ 2>/dev/null || echo "No build directory"
ls -la app/build/outputs/ 2>/dev/null || echo "No outputs directory"
ls -la app/build/outputs/apk/ 2>/dev/null || echo "No apk directory"

echo ""
echo "5. 🔄 GITHUB WORKFLOW CHECK:"
if [ -f ".github/workflows/build.yml" ]; then
    echo "✅ GitHub workflow exists"
    echo "📋 Workflow content:"
    head -20 .github/workflows/build.yml
else
    echo "❌ No GitHub workflow found!"
    # Create one immediately
    mkdir -p .github/workflows
    cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build APK
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    - run: chmod +x ./gradlew
    - run: |
        ./gradlew clean
        ./gradlew assembleDebug --no-daemon --stacktrace
    - uses: actions/upload-artifact@v4
      with:
        name: android-apk
        path: app/build/outputs/apk/**/*.apk
WORKFLOW
    echo "✅ Created basic workflow"
fi

echo ""
echo "6. 🧪 TEST BUILD LOCALLY:"
echo "🔨 Attempting local build..."
./gradlew clean
./gradlew assembleDebug --no-daemon --stacktrace

echo ""
echo "7. 📊 RESULTS:"
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "🎉 SUCCESS: APK created locally!"
    echo "📱 Path: app/build/outputs/apk/debug/app-debug.apk"
    echo "📦 Size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
else
    echo "❌ FAILED: No APK created"
    echo "🔍 Checking build logs..."
    find . -name "*.log" -type f | head -3
fi
