#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 KUANGALIA FILES ZILIZOBAKI"
echo "============================"

echo ""
echo "📁 FILES ZOTE ZILIZOBAKI:"
ls -la

echo ""
echo "📱 APP DIRECTORY STRUCTURE:"
find app -type f -name "*.java" -o -name "*.xml" -o -name "*.gradle" | head -20

echo ""
echo "🔧 GRADLE FILES CONTENT:"
echo "=== build.gradle ==="
cat build.gradle
echo ""
echo "=== app/build.gradle ==="
cat app/build.gradle
echo ""
echo "=== settings.gradle ==="
cat settings.gradle
echo ""
echo "=== gradle.properties ==="
cat gradle.properties

echo ""
echo "📋 JAVA SOURCE FILES:"
find app/src/main/java -name "*.java" -exec echo "=== {} ===" \; -exec head -5 {} \;

echo ""
echo "📄 ANDROID MANIFEST:"
cat app/src/main/AndroidManifest.xml

echo ""
echo "🎯 SASA TUJARIBU BUILD LOCALLY:"
./gradlew clean
./gradlew assembleDebug --no-daemon

if [ $? -eq 0 ] && [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "🎉 BUILD SUCCESS!"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    echo "📦 Size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
else
    echo "❌ BUILD FAILED"
    echo "🔍 Checking for errors..."
fi
