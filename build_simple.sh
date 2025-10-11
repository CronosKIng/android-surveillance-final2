#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUJENGA APK KWA NJIA RAHISI..."

# Ondoa makosa ya gradle
rm -rf .gradle
rm -rf build
rm -rf app/build

# Tumia direct commands
chmod +x gradlew

# Jaribu kujenga kwa options rahisi
./gradlew clean --no-daemon
./gradlew assembleDebug --no-daemon --no-parallel --stacktrace

# Angalia kama APK imeundwa
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "🎉 APK IMEUNDWA!"
    echo "📱 Faili: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "✅ Sasa unaweza:"
    echo "   1. Copy APK kwenye simu"
    echo "   2. Install na kutoa permissions"
    echo "   3. Weka Parent Code"
    echo "   4. App itafanya kazi kwa siri"
else
    echo "❌ APK haijaundwa. Jaribu manual build:"
    echo "   ./gradlew clean assembleDebug --no-daemon"
fi
