#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GRADLE KWA GITHUB ACTIONS..."

# 1. Rekebisha build.gradle (project level)
cat > build.gradle << 'PROJECT_GRADLE'
// Top-level build file where you can add configuration options common to all sub-projects/modules.
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
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Android Surveillance"
include ':app'
SETTINGS

# 3. Rekebisha GitHub Actions workflow
mkdir -p .github/workflows
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
      uses: actions/checkout@v3

    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Setup Android SDK
      uses: android-actions/setup-android@v2

    - name: Change wrapper permissions
      run: chmod +x ./gradlew

    - name: Build Debug APK
      run: ./gradlew assembleDebug --no-daemon

    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: surveillance-app
        path: app/build/outputs/apk/debug/app-debug.apk
        retention-days: 30

WORKFLOW

# 4. Commit na push
git add .
git commit -m "🔧 Fix GitHub Actions - Android plugin configuration
- Fixed build.gradle with proper plugin management
- Added Google and MavenCentral repositories
- Updated GitHub Actions workflow"

git push origin main

echo ""
echo "✅ FIXES ZIMEPUSH! GitHub Actions itajenga APK sasa..."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
