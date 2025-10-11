#!/bin/bash
cd ~/android-surveillance-final2

echo "🗑️ INAONDOA DUPLICATE MAINACTIVITY..."
echo "===================================="

# Ondoa MainActivity.java ya zamani
if [ -f "app/src/main/java/com/security/update/MainActivity.java" ]; then
    echo "📄 MainActivity.java imepatikana - inaondolewa"
    rm app/src/main/java/com/security/update/MainActivity.java
    echo "✅ MainActivity imeondolewa"
    
    # Pia ondoa layout yake ya zamani
    if [ -f "app/src/main/res/layout/activity_main.xml" ]; then
        rm app/src/main/res/layout/activity_main.xml
        echo "✅ activity_main.xml imeondolewa"
    fi
else
    echo "✅ Hakuna MainActivity - tayari imeondolewa"
fi

echo ""
echo "🔍 SASA FILES ZILIZOBAKI:"
find app/src/main/java -name "*.java" -exec basename {} \;

echo ""
echo "🎯 SASA TUJARIBU BUILD:"
./gradlew clean
./gradlew assembleDebug --no-daemon

if [ $? -eq 0 ] && [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "🎉 BUILD SUCCESS!"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    echo "📦 Size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    
    # Copy for easy access
    cp app/build/outputs/apk/debug/app-debug.apk ./SURVEILLANCE_APP_READY.apk
    echo "📲 Ready APK: SURVEILLANCE_APP_READY.apk"
else
    echo ""
    echo "❌ BUILD FAILED"
fi

echo ""
echo "📤 READY FOR GITHUB ACTIONS!"
echo "Run: git add . && git commit -m 'Remove duplicate MainActivity' && git push origin main"
