#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB-ONLY BUILD..."
echo "=================================="

# 1. Rekebisha gradle-wrapper.properties kwa distributionType=bin (smaller)
cat > gradle/wrapper/gradle-wrapper.properties << 'WRAPPER'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
WRAPPER

# 2. Rekebisha GitHub workflow iwe efficient
cat > .github/workflows/build.yml << 'GITHUB_WORKFLOW'
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
      
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Cache Gradle packages
      uses: actions/cache@v3
      with:
        path: |
          ~/.gradle/caches
          ~/.gradle/wrapper
        key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
        restore-keys: |
          ${{ runner.os }}-gradle-
          
    - name: Build APK
      run: |
        chmod +x ./gradlew
        ./gradlew clean
        ./gradlew assembleDebug --no-daemon --no-build-cache
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
        retention-days: 90
GITHUB_WORKFLOW

# 3. Rekebisha build.gradle iwe rahisi
cat > build.gradle << 'SIMPLE_BUILD'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
SIMPLE_BUILD

echo "✅ GitHub-only configuration fixed!"

# 4. Push moja kwa moja
echo ""
echo "📤 Inapush GitHub-only fixes..."
git add .
git commit -m "🔧 Optimize for GitHub Actions only
- Use gradle-bin for faster downloads
- Added Gradle caching
- GitHub-only build optimization"
git push origin main

echo ""
echo "✅ GITHUB-ONLY FIXES PUSHED!"
echo "📱 Sasa GitHub Actions itatumia cache na kujenga haraka!"
echo "🔗 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
