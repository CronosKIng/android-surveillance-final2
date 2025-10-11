#!/bin/bash
cd ~/android-surveillance-final2

echo "🔄 KUTENGENEZA SIMPLE WORKFLOW..."

cat > .github/workflows/build.yml << 'SIMPLE_WORKFLOW'
name: Build APK

on: [push, pull_request]

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
        
    - name: Setup Android environment
      run: |
        sudo apt-get update
        wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip
        mkdir -p android-sdk/cmdline-tools
        unzip commandlinetools-linux-8512546_latest.zip -d android-sdk/cmdline-tools
        mv android-sdk/cmdline-tools/cmdline-tools android-sdk/cmdline-tools/latest
        echo "$GITHUB_WORKSPACE/android-sdk" >> $GITHUB_PATH
        echo "ANDROID_HOME=$GITHUB_WORKSPACE/android-sdk" >> $GITHUB_ENV
        
    - name: Build APK
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug --no-daemon
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
SIMPLE_WORKFLOW

git add .
git commit -m "🔧 Simplified workflow without Android action"
git push origin main

echo "✅ Simple workflow imepush!"
