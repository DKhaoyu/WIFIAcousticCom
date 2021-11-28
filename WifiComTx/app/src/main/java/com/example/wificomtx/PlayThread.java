package com.example.wificomtx;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.MediaPlayer;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class PlayThread extends Thread{
    int SampleRate = EncodeModule.SampleRate;
    byte[] wave;
    AudioTrack mplayer;
    public static boolean isPlaying = false;
    public PlayThread(String message, TxConfig config){
        EncodeModule encoder = new EncodeModule(message, config);
        mplayer = new AudioTrack(AudioManager.STREAM_MUSIC,SampleRate,
                AudioFormat.CHANNEL_CONFIGURATION_STEREO, // ,
                AudioFormat.ENCODING_PCM_8BIT, SampleRate, AudioTrack.MODE_STREAM);
        wave = encoder.play_seq;
    }
    @Override
    public void run() {
        super.run();
        if(mplayer!=null) {
            mplayer.play();
        }
        mplayer.write(wave, 0, wave.length);
    }
}
