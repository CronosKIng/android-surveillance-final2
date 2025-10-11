#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB ACTIONS V4..."
echo "=================================="

# Rekebisha GitHub workflow kwa kutumia v4
cat > .github/workflows/build.yml << 'WORKFLOW_V4'
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Build with Gradle
      run: |
        chmod +x ./gradlew
        ./gradlew clean
        ./gradlew assembleDebug
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW_V4

echo "✅ GitHub Actions v4 configuration fixed!"

# Push moja kwa moja
echo ""
echo "📤 Inapush fixes kwenye GitHub..."
git add .
git commit -m "🔧 Update to GitHub Actions v4
- Updated checkout@v4
- Updated setup-java@v4  
- Updated upload-artifact@v4
- Fixed deprecated v3 actions"
git push origin main

echo ""
echo "✅ V4 FIXES PUSHED! Sasa GitHub Actions itafanya kazi."
echo "🔗 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
