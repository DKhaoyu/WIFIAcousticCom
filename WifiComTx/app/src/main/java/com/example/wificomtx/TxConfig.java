package com.example.wificomtx;

public class TxConfig {
    public int map_option;
    public int packet_length;
    public int pilot_length;
    public int freq;
    public TxConfig(int mod_opt_in, int packet_len_in, int pilot_len_in, int freq_in){
        map_option = mod_opt_in;
        packet_length = packet_len_in;
        pilot_length = pilot_len_in;
        freq = freq_in;
    }
}
