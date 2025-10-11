#!/bin/bash
cd ~/android-surveillance-final2

echo "🔍 KUANGALIA CODE ISSUES MOJA KWA MOJA..."

echo ""
echo "📱 CHECKING ANDROIDMANIFEST.XML:"
if [ -f "app/src/main/AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest ipo"
    # Angalia kama package name iko sahihi
    grep "package=" app/src/main/AndroidManifest.xml
else
    echo "❌ AndroidManifest haipo"
fi

echo ""
echo "📝 CHECKING JAVA FILES:"
for java_file in app/src/main/java/com/security/update/*.java; do
    if [ -f "$java_file" ]; then
        echo "🔍 $(basename $java_file):"
        # Angalia package declaration
        head -5 "$java_file" | grep -E "package|class"
        # Angalia kama kuna syntax errors
        if grep -q "error\|Error" "$java_file"; then
            echo "   ⚠️  Inaweza kuwa na errors"
        fi
    fi
done

echo ""
echo "⚙️ CHECKING BUILD.GRADLE FILES:"
echo "=== PROJECT BUILD.GRADLE ==="
head -20 build.gradle
echo ""
echo "=== APP BUILD.GRADLE ==="
head -30 app/build.gradle

echo ""
echo "🔧 TESTING GRADLE BUILD LOCALLY:"
echo "=== CLEAN ==="
./gradlew clean --console=plain
echo "=== ASSEMBLE DEBUG ==="
./gradlew assembleDebug --console=plain --stacktrace

echo ""
echo "📁 CHECKING IF APK WAS CREATED:"
find . -name "*.apk" -type f 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ APK IMEUNDWA LOCALLY!"
else
    echo "❌ APK HAJAUNDWA - Shida iko kwenye build process"
    echo ""
    echo "🎯 LET'S CHECK BUILD OUTPUTS:"
    ls -la app/build/ || echo "No build directory"
    ls -la app/build/outputs/ || echo "No outputs directory"
    ls -la app/build/reports/ || echo "No reports directory"
fi
