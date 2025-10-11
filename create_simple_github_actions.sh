#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUTENGENEZA GITHUB ACTIONS RAHISI..."

# Create GitHub Actions directory
mkdir -p .github/workflows

# Create simple workflow
cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build APK

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        java-version: '11'
    - name: Build APK
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug
    - uses: actions/upload-artifact@v3
      with:
        name: app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ GitHub Actions imeundwa!"
echo ""
echo "📤 Inapush kwa GitHub..."
git add .
git commit -m "📱 Add simple GitHub Actions workflow"
git push origin main

echo ""
echo "✅ IMEPUSH! Sasa:"
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "📱 Subiri APK ijengwe, kisha download kwenye Artifacts"
