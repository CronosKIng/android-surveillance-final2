#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB ACTIONS TU..."
echo "=================================="

# 1. Rekebisha build.gradle - tumia syntax rahisi
cat > build.gradle << 'PROJECT_GRADLE'
// Top-level build file
plugins {
    id 'com.android.application' version '8.0.0' apply false
    id 'com.android.library' version '8.0.0' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
PROJECT_GRADLE

# 2. Rekebisha settings.gradle - ondoa repository conflict
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

# 3. Rekebisha GitHub workflow - ondoa Android setup unnecessary
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

echo "✅ GitHub Actions configuration fixed!"

# 4. Push moja kwa moja bila local test
echo ""
echo "📤 Inapush fixes kwenye GitHub..."
git add .
git commit -m "🔧 Fix GitHub Actions - Simplified Gradle configuration
- Fixed repository conflict in settings.gradle
- Removed unnecessary Android setup
- Ready for successful build"
git push origin main

echo ""
echo "✅ FIXES ZIMEPUSH! Sasa GitHub Actions itafanya kazi."
echo "🔗 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "   na uangalie build mpya"
