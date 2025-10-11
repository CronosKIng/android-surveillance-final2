#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FIXING BUILD ISSUE - APK NOT BEING CREATED"

# Rekebisha workflow kuonyesha errors wazi
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
    - name: Build with detailed output
      run: |
        chmod +x gradlew
        echo "=== CLEANING ==="
        ./gradlew clean
        echo "=== BUILDING DEBUG APK ==="
        ./gradlew assembleDebug --stacktrace --info
        echo "=== CHECKING BUILD RESULTS ==="
        find . -name "*.apk" -type f
        echo "=== BUILD DIRECTORY STRUCTURE ==="
        find app/build/ -type f -name "*.apk" 2>/dev/null || echo "No APK files found"
        ls -la app/ || echo "No app directory"
        ls -la app/build/ || echo "No build directory"
        ls -la app/build/outputs/ || echo "No outputs directory"
    - name: Upload any APK found
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: build-artifacts
        path: |
          app/build/outputs/
          *.apk
WORKFLOW

echo "✅ Build workflow imerekebishwa kuonyesha details!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Debug: Show why APK is not being created"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa tutaona kosa wapi."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
