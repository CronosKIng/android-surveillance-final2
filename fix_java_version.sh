#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA JAVA VERSION..."

# 1. Angalia Java version iliyopo
echo "📊 Java Version ya sasa:"
java -version
javac -version 2>/dev/null || echo "❌ Javac haipo"

# 2. Install Java 17 (inayofaa kwa Gradle 7.5)
echo "📥 Inasakinisha Java 17..."
pkg update -y
pkg install openjdk-17 -y

# 3. Set Java 17 as default
export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 4. Hakikisha Java 17 inatumika
echo "🔍 Java Version mpya:"
java -version

# 5. Futa gradle cache
rm -rf ~/.gradle
rm -rf .gradle
rm -rf build
rm -rf app/build

# 6. Jaribu kujenga tena
echo "🔨 Inajenga na Java 17..."
./gradlew clean assembleDebug --no-daemon --stacktrace

if [ $? -eq 0 ]; then
    echo ""
    echo "🎊 🎊 🎊 APK IMEBUIDIWA KIKAMILIFU! 🎊 🎊 🎊"
    echo "📱 APK: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "✅ Sasa tumia commands hizi kila wakati kabla ya kujenga:"
    echo "   export JAVA_HOME=/data/data/com.termux/files/usr/lib/jvm/java-17-openjdk"
    echo "   export PATH=\$JAVA_HOME/bin:\$PATH"
    echo "   ./gradlew clean assembleDebug --no-daemon"
else
    echo "❌ Build imeshindikana. Tuna njia mbadala..."
    
    # Njia mbadala - tumia Docker
    echo "🐳 Kujaribu kujenga kwa Docker..."
    docker run --rm -v $(pwd):/project -w /project openjdk:17-jdk ./gradlew clean assembleDebug --no-daemon
fi
