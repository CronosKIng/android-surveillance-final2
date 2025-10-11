#!/bin/bash
cd ~/android-surveillance-final2

echo "📁 PROJECT STRUCTURE ANALYSIS"
echo "=============================="

echo ""
echo "🔍 ROOT DIRECTORY FILES:"
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
echo "📋 JAVA SOURCE FILES:"
find app/src/main/java -name "*.java" -exec echo "=== {} ===" \; -exec head -10 {} \;

echo ""
echo "📄 ANDROID MANIFEST:"
cat app/src/main/AndroidManifest.xml

echo ""
echo "🎯 CHECKING FOR APK:"
find . -name "*.apk" -type f 2>/dev/null

echo ""
echo "🔍 GITHUB ACTIONS WORKFLOWS:"
find .github -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -5
