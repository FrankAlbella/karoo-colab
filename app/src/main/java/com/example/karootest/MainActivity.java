package com.example.karootest;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.example.karootest.service.RandPartnerHRService;


public class MainActivity extends AppCompatActivity {

    private boolean serviceStarted = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final Button button = findViewById(R.id.button);
        final TextView label = findViewById(R.id.label_main);

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                /*
                startActivity(
                        FlutterActivity.createDefaultIntent(getApplicationContext())
                );
                */

                if(serviceStarted) {
                    stopService(new Intent(getApplicationContext(), RandPartnerHRService.class));
                    button.setText("Start Service");
                }
                else {
                    startService(new Intent(getApplicationContext(), RandPartnerHRService.class));
                    button.setText("Stop Service");
                }


            }
        });
    }
}