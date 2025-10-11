#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB ACTIONS KWA VERSION MPYA..."

# Rekebisha workflow kwa version mpya
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
    - name: Build APK
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug
    - uses: actions/upload-artifact@v4
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ GitHub Actions imerekebishwa kwa version mpya!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "🔧 Update GitHub Actions to v4"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa GitHub Actions itafanya kazi."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
