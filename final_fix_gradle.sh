#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FINAL FIX FOR GRADLE 9.1.0..."

# 1. Rekebisha build.gradle kwa Gradle 9.1.0
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

# 2. Rekebisha settings.gradle kwa Gradle 9.1.0
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

rootProject.name = "Android Surveillance"
include ':app'
SETTINGS

# 3. Rekebisha app/build.gradle
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

# 4. Rekebisha GitHub Actions workflow
cat > .github/workflows/build.yml << 'WORKFLOW'
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
        
    - name: Setup Android SDK
      run: |
        yes | sdkmanager --licenses
        sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
        
    - name: Build with Gradle
      run: |
        chmod +x gradlew
        ./gradlew assembleDebug --no-daemon
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

# 5. Update gradle wrapper kwa version sahihi
./gradlew wrapper --gradle-version=8.0 --distribution-type=all

git add .
git commit -m "🔧 FINAL FIX: Gradle 9.1.0 compatibility
- Fixed repository configuration for Gradle 9.1.0
- Updated plugin management
- Simplified build configuration"
git push origin main

echo ""
echo "✅ FINAL FIX PUSHED! Hii ndio fix ya mwisho..."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
