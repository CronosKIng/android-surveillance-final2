#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FIXING JAVA VERSION FOR GITHUB ACTIONS..."

# Rekebisha workflow kwa Java 17
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
        ./gradlew assembleDebug
    - uses: actions/upload-artifact@v4
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ GitHub Actions imerekebishwa kwa Java 17!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Fix: Use Java 17 for Android build"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa GitHub Actions itafanya kazi na Java 17."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
