package edu.uf.karoo_collab;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.os.Bundle;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "edu.uf.karoo_collab";

    private static double myHR = 0;
    private static double myPower = 0;

    private static double partnerHR = 0;
    private static double partnerPower = 0;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();

                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else if (call.method.equals("setPartnerHR")){
                                setPartnerHR(call.argument("hr"));
                                result.success(null);
                            } else if (call.method.equals("setPartnerPower")){
                                setPartnerPower(call.argument("power"));
                                result.success(null);
                            } else if (call.method.equals("getMyHR")){
                                double hr = getMyHR();
                                result.success(hr);
                            } else if (call.method.equals("getMyPower")){
                                double hr = getMyHR();
                                result.success(hr);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
    private int getBatteryLevel() {
        int batteryLevel = -1;

        // this assumes we are >= Android Lollipop (5.0)
        BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
        batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);

        return batteryLevel;
    }

    public static void setMyHR(double hr) {
        myHR = hr;
    }

    public static double getMyHR() {
        return myHR;
    }

    public static void setMyPower(double power) {
        myPower = power;
    }

    public static double getMyPower() {
        return myPower;
    }

    private void setPartnerHR(double hr) {
        partnerHR = hr;
    }
    public static double getPartnerHR()
    {
        return partnerHR;
    }
    private void setPartnerPower(double power) {
        partnerPower = power;
    }
    public static double getPartnerPower()
    {
        return partnerPower;
    }


}
