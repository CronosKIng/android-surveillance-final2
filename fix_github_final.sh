#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FINAL FIX FOR GITHUB ACTIONS..."

# Rekebisha workflow kwa sahihi kabisa
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
        java-version: '11'
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

echo "✅ GitHub Actions imerekebishwa kikamilifu!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Fix: Add distribution to Java setup"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa GitHub Actions itafanya kazi."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
