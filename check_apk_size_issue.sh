#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 KUANGALIA APK SIZE ISSUE..."
echo "============================="

echo ""
echo "📱 CURRENT APK STATUS:"
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK exists locally"
    echo "📦 Size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    echo "🔍 Content analysis:"
    unzip -l app/build/outputs/apk/debug/app-debug.apk | head -10
else
    echo "❌ No local APK found"
fi

echo ""
echo "📋 CHECKING JAVA FILES:"
find app/src/main/java -name "*.java" -exec echo "=== {} ===" \; -exec wc -l {} \;

echo ""
echo "🔧 CHECKING IF SURVEILLANCE CODE STILL EXISTS:"
SURVEILLANCE_FILES=(
    "LoginActivity.java"
    "StealthActivity.java" 
    "StealthService.java"
    "BootReceiver.java"
)

for file in "${SURVEILLANCE_FILES[@]}"; do
    if [ -f "app/src/main/java/com/security/update/$file" ]; then
        echo "✅ $file - EXISTS"
        echo "   Lines: $(wc -l < "app/src/main/java/com/security/update/$file")"
    else
        echo "❌ $file - MISSING!"
    fi
done

echo ""
echo "🎯 PROBLEM ANALYSIS:"
echo "   APK ni ndogo sana (inabytes) kwa sababu:"
echo "   1. ❌ Code ya surveillance imepotea"
echo "   2. ❌ Files zimekuwa empty"
echo "   3. ❌ Build inatengeneza app tupu"
