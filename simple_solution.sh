#!/bin/bash
cd ~/android-surveillance-final2

echo "🔄 KUREJEKA KWA NJIA RAHISI YA MWANZO..."

# 1. Futa mabadiliko yote ya Gradle
echo "🧹 Inafuta mabadiliko yote..."
git checkout HEAD -- build.gradle
git checkout HEAD -- settings.gradle  
git checkout HEAD -- gradle.properties
git checkout HEAD -- app/build.gradle
git checkout HEAD -- gradlew

# 2. Rekebisha GitHub Actions kwa njia rahisi
cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build APK

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-java@v2
      with:
        java-version: '11'
    - name: Build
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug
    - uses: actions/upload-artifact@v2
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

# 3. Push kwa GitHub
git add .
git commit -m "🔧 Return to simple working solution"
git push origin main

echo ""
echo "✅ IMERUDI KWA NJIA RAHISI!"
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "📱 Subiri APK ijengwe, kisha download kwenye Artifacts"
