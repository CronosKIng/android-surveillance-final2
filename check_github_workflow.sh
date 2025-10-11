#!/bin/bash
cd ~/android-surveillance-final2

echo "🔗 KUANGALIA GITHUB ACTIONS WORKFLOW"
echo "==================================="

if [ -f ".github/workflows/build.yml" ]; then
    echo "✅ GitHub workflow ipo"
    echo "📋 Workflow content:"
    cat .github/workflows/build.yml
else
    echo "❌ Hakuna GitHub workflow"
    echo "📝 Inaunda workflow..."
    mkdir -p .github/workflows
    cat > .github/workflows/build.yml << 'WORKFLOW'
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
      uses: actions/checkout@v3
      
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Build with Gradle
      run: |
        chmod +x ./gradlew
        ./gradlew clean
        ./gradlew assembleDebug
        
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW
    echo "✅ GitHub workflow created"
fi

echo ""
echo "🚀 SASA PUSH KWENYE GITHUB:"
git add .
git status

echo ""
echo "📋 RUN THESE COMMANDS:"
echo "   git commit -m 'Fix: Remove duplicate MainActivity and cleanup'"
echo "   git push origin main"
echo ""
echo "🔗 THEN GO TO: https://github.com/CronosKIng/android-surveillance-final2/actions"
