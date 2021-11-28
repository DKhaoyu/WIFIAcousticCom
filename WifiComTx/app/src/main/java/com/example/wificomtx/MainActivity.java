package com.example.wificomtx;

import androidx.appcompat.app.AppCompatActivity;

import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Environment;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;

import java.io.File;

public class MainActivity extends AppCompatActivity {
    EditText message_in;
    EditText freq_in;
    Spinner map_opt_sel;
    EditText packet_size_in;
    EditText pilot_size_in;
    PlayThread mthread;
    Button send;
    String message;
    int freq;
    int map_opt;
    int packet_size;
    int pilot_size;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        send = (Button) findViewById(R.id.sendBtn);
        message_in = (EditText) findViewById(R.id.messageIn);
        message_in.setInputType(InputType.TYPE_TEXT_FLAG_IME_MULTI_LINE);
        message_in.setGravity(Gravity.TOP);
        freq_in = (EditText) findViewById(R.id.freqIn);
        map_opt_sel = (Spinner) findViewById(R.id.modOptSel);
        packet_size_in = (EditText) findViewById(R.id.packetSizeIn);
        pilot_size_in = (EditText) findViewById(R.id.pilotSizeIn);
        map_opt_sel.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
               map_opt = position;
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
        send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                freq = Integer.parseInt(freq_in.getText().toString());
                packet_size = Integer.parseInt(packet_size_in.getText().toString());
                pilot_size = Integer.parseInt(pilot_size_in.getText().toString());
                TxConfig config = new TxConfig(map_opt, packet_size, pilot_size, freq);
                message = message_in.getText().toString();
                mthread = new PlayThread(message, config);
                mthread.start();
            }
        });

    }
}