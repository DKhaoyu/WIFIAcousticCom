package com.example.wificomtx;

public class Hamming {
    public int N;
    public double[] window;
    public Hamming(int n){
        N = n;
        window = new double[N];
        double a0 = 0.53836;
        for(int i=0; i<N; i++){
            window[i] = a0-(1-a0)*Math.cos((double)(2*Math.PI*i)/(double)(N-1));
        }
    }
}
