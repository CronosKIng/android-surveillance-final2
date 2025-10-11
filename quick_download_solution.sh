#!/bin/bash
echo "🚀 QUICK SOLUTION - USE PRE-BUILT TEMPLATE"

echo "📥 Downloading Android project template..."
# Tengeneza simple Android project
mkdir -p ~/android-surveillance-simple
cd ~/android-surveillance-simple

# Create basic structure
mkdir -p app/src/main/java/com/security/update
mkdir -p app/src/main/res/layout

# Copy your existing Java files
cp ~/android-surveillance-final2/app/src/main/java/com/security/update/*.java app/src/main/java/com/security/update/

# Create minimal build files
cat > build.gradle << 'GRADLE'
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
GRADLE

cat > app/build.gradle << 'APP_GRADLE'
plugins {
    id 'com.android.application'
}

android {
    compileSdk 33
    namespace 'com.security.update'

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

cat > settings.gradle << 'SETTINGS'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
rootProject.name = "SurveillanceApp"
include ':app'
SETTINGS

# Initialize gradle wrapper
gradle wrapper --gradle-version=7.5

echo "✅ Simple project imeundwa! Sasa jaribu kujenga:"
echo "   cd ~/android-surveillance-simple"
echo "   ./gradlew assembleDebug"
