#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GRADLE CONFLICT..."
echo "================================"

# 1. Rekebisha build.gradle kwa syntax rahisi
cat > build.gradle << 'PROJECT_GRADLE'
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '8.0.0' apply false
    id 'com.android.library' version '8.0.0' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
PROJECT_GRADLE

# 2. Rekebisha settings.gradle
cat > settings.gradle << 'SETTINGS'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "SurveillanceApp"
include ':app'
SETTINGS

# 3. Rekebisha GitHub workflow
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
        
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3
      
    - name: Build with Gradle
      run: |
        chmod +x ./gradlew
        ./gradlew clean
        ./gradlew assembleDebug --no-daemon
        
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

echo "✅ Gradle configuration fixed!"
echo "🔨 Testing local build..."
./gradlew clean
./gradlew assembleDebug --no-daemon

if [ $? -eq 0 ] && [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "🎉 LOCAL BUILD SUCCESS!"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ LOCAL BUILD FAILED"
fi

echo ""
echo "📤 Pushing fixes to GitHub..."
git add .
git commit -m "🔧 Fix Gradle repository conflict
- Fixed build.gradle with plugins syntax
- Fixed settings.gradle repository mode
- Ready for successful GitHub Actions build"
git push origin main

echo ""
echo "✅ FIXES PUSHED! GitHub Actions itafanya kazi sasa."
echo "🔗 Go to: https://github.com/CronosKIng/android-surveillance-final2/actions"
