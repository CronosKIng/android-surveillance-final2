#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FIXING BUILD COMMAND IN GITHUB ACTIONS..."

# Rekebisha workflow kwa kuwa na build command sahihi
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
    - name: Build APK
      run: |
        chmod +x gradlew
        ./gradlew clean
        ./gradlew assembleDebug
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ Build command imerekebishwa!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Fix: Correct build command - assembleDebug"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa GitHub Actions itajenga APK."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
