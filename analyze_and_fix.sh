#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 ANALYZING CURRENT SITUATION..."

# 1. Angalia faili zilizopo
echo "📁 FILES IN DIRECTORY:"
ls -la

# 2. Angalia kama kuna source code
echo ""
echo "📱 CHECKING SOURCE CODE:"
if [ -d "app/src/main/java/com/security/update" ]; then
    echo "✅ Source code ipo"
    ls app/src/main/java/com/security/update/
else
    echo "❌ Hakuna source code"
fi

# 3. Angalia kama kuna APK iliyojengwa
echo ""
echo "📦 CHECKING FOR EXISTING APK:"
find . -name "*.apk" -type f 2>/dev/null

# 4. Test Gradle
echo ""
echo "🔧 TESTING GRADLE:"
if [ -f "gradlew" ]; then
    chmod +x gradlew
    ./gradlew --version || echo "❌ Gradle haifanyi kazi"
else
    echo "❌ Hakuna gradlew file"
fi

# 5. Angalia build configuration
echo ""
echo "⚙️ CHECKING BUILD CONFIGURATION:"
[ -f "build.gradle" ] && echo "✅ build.gradle ipo" || echo "❌ Hakuna build.gradle"
[ -f "settings.gradle" ] && echo "✅ settings.gradle ipo" || echo "❌ Hakuna settings.gradle"
[ -f "gradle.properties" ] && echo "✅ gradle.properties ipo" || echo "❌ Hakuna gradle.properties"

echo ""
echo "📊 SUMMARY:"
echo "   Source Code: $(if [ -d "app/src/main/java/com/security/update" ]; then echo '✅'; else echo '❌'; fi)"
echo "   Gradle Wrapper: $(if [ -f "gradlew" ]; then echo '✅'; else echo '❌'; fi)"
echo "   Build Files: $(if [ -f "build.gradle" ] && [ -f "settings.gradle" ]; then echo '✅'; else echo '❌'; fi)"
echo "   Existing APK: $(find . -name "*.apk" -type f 2>/dev/null | head -1 | xargs -I {} echo '✅ {}' || echo '❌')"
