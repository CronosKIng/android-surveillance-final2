#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GITHUB ACTIONS V2..."

# Rekebisha workflow kwa version mpya
cat > .github/workflows/build-apk.yml << 'WORKFLOW'
name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

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

    - name: Setup Android SDK
      uses: android-actions/setup-android@v3

    - name: Make gradlew executable
      run: chmod +x ./gradlew

    - name: Build with Gradle
      run: ./gradlew assembleDebug --no-daemon

    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
        retention-days: 30

    - name: Upload Build Results
      uses: actions/upload-artifact@v4
      with:
        name: build-outputs
        path: app/build/outputs/
WORKFLOW

# Pia rekebisha build.gradle kwa compatibility
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

# Rekebisha app/build.gradle
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

# Update gradle wrapper
./gradlew wrapper --gradle-version=8.0 --distribution-type=all

git add .
git commit -m "🔧 Fix GitHub Actions - Update to latest versions
- Updated actions/upload-artifact@v4
- Updated actions/checkout@v4  
- Updated Gradle to 8.0.0
- Fixed compatibility issues"

git push origin main

echo ""
echo "✅ FIXES ZIMEPUSH! GitHub Actions itafanya kazi sasa..."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
