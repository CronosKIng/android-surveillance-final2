#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 DEBUGGING GITHUB BUILD ISSUE..."

# Rekebisha workflow kuonyesha error details
cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build APK

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    - name: Build APK with debug info
      run: |
        chmod +x gradlew
        ./gradlew clean
        ./gradlew assembleDebug --stacktrace --info
        echo "📁 Checking if APK exists:"
        find . -name "*.apk" -type f
        echo "📁 Build outputs:"
        ls -la app/build/outputs/ || echo "No build outputs"
        ls -la app/build/outputs/apk/ || echo "No apk directory"
        ls -la app/build/outputs/apk/debug/ || echo "No debug directory"
    - name: Upload APK if exists
      uses: actions/upload-artifact@v4
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ GitHub Actions imerekebishwa kuonyesha details!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Debug: Show build details in GitHub Actions"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa GitHub Actions itaonyesha kosa wapi."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
