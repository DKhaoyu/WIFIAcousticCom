package com.example.wificomtx;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.lang.Math;
import java.util.Arrays;

public class EncodeModule {
    public final int HEIGHT = 127;
    public final double PI = 3.1415926;
    public int FREQ;
    public static int SampleRate = 8000;
    public int map_option;          // 0: 16QAM, 1:64QAM;
    public int pilot_length;        //byte count
    public int packet_length;      //byte count
    public double f1 = 100;
    public double f2 = 900;
    public double Ts;
    public int sps = 480;
    public int byte_len;
    public int symbol_len;
    public int bit_len;                 //small-ending
    public int packet_num;              //include the final one
    public int tail_len;
    public String message;
    public byte[] raw_byte;
    public boolean[] bit_seq;
    public double[] I_seq;
    public double[] Q_seq;
    public double[] header;
    public byte[] play_seq;
    public  double[] window;
    EncodeModule(String message_in, TxConfig config){
        map_option = config.map_option;
        packet_length = config.packet_length;
        pilot_length = config.pilot_length;
        FREQ = config.freq;
        message = message_in;
        raw_byte = message.getBytes(StandardCharsets.UTF_8);
        byte_len = message.length();
        bit_len = 8*byte_len;
        bit_seq = new boolean[bit_len];
        packet_num = (int) Math.ceil((double)byte_len/(double) (packet_length-pilot_length-1));
        tail_len = byte_len%(packet_length-pilot_length-1);
        Ts = (double) ((double)(sps)/(double)(SampleRate));
        Hamming ham = new Hamming(sps);
        window = ham.window;
        byte temp;
        for(int byte_cnt=0; byte_cnt<message.length(); byte_cnt++) {
            temp = raw_byte[byte_cnt];
            for (int bit_cnt = 7; bit_cnt >= 0; bit_cnt--) {
                bit_seq[8*byte_cnt+bit_cnt] = ((temp&1)==1);            //small-ending
                temp = (byte)(temp>>1);
            }
        }
        Mapping();
        GenHeader();
        Assemble();
    }
    public void Mapping(){
        if (this.map_option == 0){
            this.symbol_len = bit_len/4;
            I_seq = new double[packet_num+symbol_len];
            Q_seq = new double[packet_num+symbol_len];
            int id;
            QAM dot;
            if (tail_len>0) {
                for (int i = 0; i < packet_num; i++) {
                    if (i<packet_num-1){
                        for (int j = 0; j <2*(packet_length-1-pilot_length)+1; j++) {
                            int sym_pos = i * (2 * (packet_length - pilot_length - 1) + 1) + j;
                            if (j == 0) {
                                dot = new QAM(1, packet_length - pilot_length - 1);
                                I_seq[sym_pos] = dot.I;
                                Q_seq[sym_pos] = dot.Q;
                            } else {
                                int bit_start_pos = 4 * (sym_pos - i - 1);
                                id = (bit_seq[bit_start_pos] ? 1 : 0) + 2 * (bit_seq[bit_start_pos + 1] ? 1 : 0) + 4 * (bit_seq[bit_start_pos + 2] ? 1 : 0) + 8 * (bit_seq[bit_start_pos + 3] ? 1 : 0);
                                dot = new QAM(0, id);
                                I_seq[sym_pos] = dot.I;
                                Q_seq[sym_pos] = dot.Q;
                            }
                        }
                    }
                    else{
                        int tail_sym_start = i * (2 * (packet_length - pilot_length - 1) + 1);
                        dot = new QAM(1, tail_len);
                        I_seq[tail_sym_start] = dot.I;
                        Q_seq[tail_sym_start] = dot.Q;
                        for (int j = 0; j<2*tail_len; j++){
                            int sym_pos = i * (2 * (packet_length - pilot_length - 1) + 1) + j + 1;
                            int bit_start_pos = 4 * (sym_pos - i - 1);
                            id = (bit_seq[bit_start_pos] ? 1 : 0) + 2 * (bit_seq[bit_start_pos + 1] ? 1 : 0) + 4 * (bit_seq[bit_start_pos + 2] ? 1 : 0) + 8 * (bit_seq[bit_start_pos + 3] ? 1 : 0);
                            dot = new QAM(0, id);
                            I_seq[sym_pos] = dot.I;
                            Q_seq[sym_pos] = dot.Q;
                        }
                    }
                }
            }
            else{
                for (int i =0; i<packet_num; i++){
                    for (int j = 0; j <2*(packet_length-1-pilot_length)+1; j++){
                        int sym_pos = i * (2*(packet_length-pilot_length-1)+1)+ j;
                        if(j == 0) {
                            dot = new QAM(1, packet_length-pilot_length-1);
                            I_seq[sym_pos] = dot.I;
                            Q_seq[sym_pos] = dot.Q;
                        }
                        else{
                            int bit_start_pos = 4*(sym_pos-j-1);
                            id = (bit_seq[bit_start_pos]?1:0)+2*(bit_seq[bit_start_pos+1]?1:0)+4*(bit_seq[bit_start_pos+2]?1:0)+8*(bit_seq[bit_start_pos+3]?1:0);
                            dot = new QAM(0, id);
                            I_seq[sym_pos] = dot.I;
                            Q_seq[sym_pos] = dot.Q;
                        }
                    }

                }
            }
        }
        else if(map_option == 1){

        }
    }
    public void GenHeader(){
        if (map_option == 0) {
            int chirp_len = 2*sps;
            header = new double[chirp_len*pilot_length];
            double[] t = new double[chirp_len];
            double u0 = (f2-f1)/(2*Ts);
            for(int i=0; i<pilot_length; i++) {
                for (int j = 0; j < chirp_len; j++) {
                    t[j] = (double) (j) / (double)SampleRate;
                    header[i*chirp_len+j] = Math.cos(2 * PI * f1 * t[j] + PI * u0 * t[j] * t[j]);
                }
            }

        }
    }
    public void Assemble(){
        if (map_option ==0) {
            int full_packet_sample = pilot_length*2*sps+2*sps+(packet_length-pilot_length-1)*2*sps;
            int[] sym_len_seq = new int[packet_num];
            for(int i=0; i<packet_num; i++){
                sym_len_seq[i] = packet_length-pilot_length-1;
            }
            double[] info_I;
            double[] info_Q;
            int i,j,n;
            int tail_packet_sample = pilot_length * 2 * sps + 2*sps + 2*tail_len*sps;
            sym_len_seq[packet_num-1] = (tail_len>0)?2*tail_len:2*(packet_length-pilot_length-1);
            play_seq = (tail_len>0)?new byte[(packet_num-1)*full_packet_sample+tail_packet_sample]:new byte[packet_num*full_packet_sample];
            for (i=0; i<packet_num; i++){
                for (j = 0; j < pilot_length * 2 * sps; j++) {
                    play_seq[i * full_packet_sample + j] = (byte) (HEIGHT * header[j]);
                }
                double t;
                for (j = 0; j < 2 * sps; j++) {
                    t = (double) j / (double) SampleRate;
                    play_seq[i * full_packet_sample + pilot_length * 2 * sps + j] = (byte) (HEIGHT * ((I_seq[i * (2 * (packet_length - pilot_length - 1) + 1)] * Math.cos(2 * PI * FREQ * t))
                            - Q_seq[i * (2 * (packet_length - pilot_length - 1) + 1)] * Math.sin(2 * PI * FREQ * t)));
                }
                int sym_len = sym_len_seq[i];
                info_I = new double[sym_len*sps];
                info_Q = new double[sym_len*sps];
                int sym_id;
                for (j = 0; j < sym_len; j++) {
                    sym_id = 2 * (packet_length - pilot_length - 1) * i + j + 1;
                    for (n = 0; n < sps; n++) {
                        info_I[j * sps + n] = I_seq[sym_id] * window[n];
                        info_Q[j * sps + n] = Q_seq[sym_id] * window[n];
                    }
                }
                for (j = 0; j < sym_len* sps; j++) {
                    t = (double) j / (double) SampleRate;
                    play_seq[i * full_packet_sample + pilot_length * 2 * sps + 2 * sps + j] = (byte) (HEIGHT * (info_I[j] * Math.cos(2 * PI * FREQ * t) - info_Q[j] * Math.sin(2 * PI * FREQ * t)));
                }
            }
        }
    }
}
