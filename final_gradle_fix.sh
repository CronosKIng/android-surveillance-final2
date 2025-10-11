#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 FINAL GRADLE WRAPPER FIX..."

# 1. Create gradle wrapper manually
mkdir -p gradle/wrapper
cat > gradle/wrapper/gradle-wrapper.properties << 'WRAPPER_PROPS'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
WRAPPER_PROPS

# 2. Download gradle wrapper jar
wget -O gradle/wrapper/gradle-wrapper.jar https://github.com/gradle/gradle/raw/master/gradle/wrapper/gradle-wrapper.jar

# 3. Create gradlew script
cat > gradlew << 'GRADLEW'
#!/bin/bash

# Determine script location and resolve symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Use local gradle distribution if available
if [ -d "$DIR/gradle-8.0" ]; then
    GRADLE_HOME="$DIR/gradle-8.0"
else
    GRADLE_HOME="$DIR/gradle/wrapper/dists/gradle-8.0-bin/*/gradle-8.0"
fi

# Execute gradle with the same arguments
exec "$GRADLE_HOME/bin/gradle" "$@"
GRADLEW

# 4. Make executable
chmod +x gradlew

# 5. Create proper GitHub Actions workflow
cat > .github/workflows/build.yml << 'WORKFLOW'
name: Build APK

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Setup Gradle Wrapper
      run: |
        chmod +x gradlew
        ./gradlew --version
        
    - name: Build APK
      run: ./gradlew assembleDebug --no-daemon
        
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
WORKFLOW

# 6. Test locally first
echo "🔨 Testing local build..."
./gradlew --version

if [ $? -eq 0 ]; then
    echo "✅ Gradle wrapper inafanya kazi!"
    ./gradlew assembleDebug --no-daemon
    
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "🎉 LOCAL BUILD SUCCESS!"
        cp app/build/outputs/apk/debug/app-debug.apk ./FINAL_APP.apk
    fi
fi

# 7. Push to GitHub
git add .
git commit -m "🔧 FINAL: Manual Gradle wrapper creation
- Created gradlew script manually
- Added gradle-wrapper.properties
- Fixed GitHub Actions workflow"
git push origin main

echo ""
echo "✅ FINAL FIX PUSHED! Sasa GitHub Actions itafanya kazi."
echo "🌐 Nenda: https://github.com/CronosKIng/android-surveillance-final2/actions"
