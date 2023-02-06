package com.example.karootest.service;

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;

import androidx.annotation.Nullable;

import io.hammerhead.sdk.v0.SdkContext;

public class RandPartnerHRService extends Service {
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intend, int flags, int startId) {
        final Handler handler = new Handler();
        final int delay = 1000; //ms
        final SdkContext kvStore = SdkContext.buildSdkContext(getApplicationContext());

        handler.postDelayed(new Runnable() {
            @Override
            public void run() {

            }
        }, 0);

        return Service.START_STICKY_COMPATIBILITY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
