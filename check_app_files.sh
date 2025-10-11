#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 KUANGALIA FILES ZA APPLICATION..."

echo ""
echo "📁 CHECKING MAIN DIRECTORY STRUCTURE:"
ls -la

echo ""
echo "📱 CHECKING APP SOURCE CODE:"
if [ -d "app/src/main/java/com/security/update" ]; then
    echo "✅ Source directory exists"
    echo ""
    echo "📄 JAVA FILES:"
    ls -la app/src/main/java/com/security/update/*.java
    echo ""
    echo "📋 FILE CONTENTS SUMMARY:"
    for file in app/src/main/java/com/security/update/*.java; do
        echo "📝 $(basename $file): $(wc -l < "$file") lines"
    done
else
    echo "❌ Source directory doesn't exist"
fi

echo ""
echo "⚙️ CHECKING ANDROID MANIFEST:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest.xml exists"
    echo "📄 Content preview:"
    head -20 app/src/main/AndroidManifest.xml
else
    echo "❌ AndroidManifest.xml missing"
fi

echo ""
echo "📦 CHECKING GRADLE FILES:"
[ -f "build.gradle" ] && echo "✅ build.gradle exists" || echo "❌ build.gradle missing"
[ -f "app/build.gradle" ] && echo "✅ app/build.gradle exists" || echo "❌ app/build.gradle missing"
[ -f "settings.gradle" ] && echo "✅ settings.gradle exists" || echo "❌ settings.gradle missing"
[ -f "gradlew" ] && echo "✅ gradlew exists" || echo "❌ gradlew missing"

echo ""
echo "🔧 CHECKING GITHUB ACTIONS:"
if [ -d ".github/workflows" ]; then
    echo "✅ GitHub Actions exists"
    ls -la .github/workflows/
else
    echo "❌ No GitHub Actions"
fi

echo ""
echo "📊 SUMMARY:"
echo "   Java Files: $(find app/src/main/java/com/security/update -name "*.java" 2>/dev/null | wc -l)"
echo "   AndroidManifest: $(if [ -f "app/src/main/AndroidManifest.xml" ]; then echo '✅'; else echo '❌'; fi)"
echo "   Gradle Files: $(if [ -f "build.gradle" ] && [ -f "app/build.gradle" ]; then echo '✅'; else echo '❌'; fi)"
echo "   GitHub Actions: $(if [ -d ".github/workflows" ]; then echo '✅'; else echo '❌'; fi)"

echo ""
echo "🎯 CRITICAL FILES CHECK:"
critical_files=(
    "app/src/main/java/com/security/update/LoginActivity.java"
    "app/src/main/java/com/security/update/StealthService.java"
    "app/src/main/java/com/security/update/StealthActivity.java"
    "app/src/main/java/com/security/update/BootReceiver.java"
    "app/src/main/AndroidManifest.xml"
    "build.gradle"
    "app/build.gradle"
)

for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING!"
    fi
done

echo ""
echo "📝 FILE CONTENT SAMPLES:"
if [ -f "app/src/main/java/com/security/update/LoginActivity.java" ]; then
    echo ""
    echo "📄 LoginActivity.java (first 5 lines):"
    head -5 app/src/main/java/com/security/update/LoginActivity.java
fi

if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo ""
    echo "📄 AndroidManifest.xml (first 10 lines):"
    head -10 app/src/main/AndroidManifest.xml
fi
