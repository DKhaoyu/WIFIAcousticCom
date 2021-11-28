package com.example.wificomtx;

public class QAM {
    public double I;
    public double Q;
    public double A;
    public int option;
    public QAM(int option, int id){
        this.option = option;
        if (option == 0){               // 16QAM
            int quadrant_id = id/4;
            int amp_id = id%4;
            A = 0.2357;
            double temp_I=-1;
            double temp_Q=-1;
            switch (amp_id){
                case 0:
                    temp_I = A;
                    temp_Q = A;
                    break;
                case 1:
                    temp_I = A;
                    temp_Q = 3*A;
                    break;
                case 2:
                    temp_I = 3*A;
                    temp_Q = A;
                    break;
                case 3:
                    temp_I = 3*A;
                    temp_Q = 3*A;
                    break;
            }
            switch (quadrant_id){
                case 0:
                    I = temp_I;
                    Q = temp_Q;
                    break;
                case 1:
                    I = temp_I;
                    Q = -temp_Q;
                    break;
                case 2:
                    I = -temp_I;
                    Q = temp_Q;
                    break;
                case 3:
                    I = -temp_I;
                    Q = -temp_Q;
                    break;
            }
        }
        else{
            A = 0.101;                  // 64QAM
            int I_id = id%8;
            int Q_id = id/8;
            switch (I_id){
                case 0:
                    I = -7*A;
                    break;
                case 1:
                    I = -5*A;
                    break;
                case 2:
                    I = -A;
                    break;
                case 3:
                    I = -3*A;
                    break;
                case 4:
                    I = 7*A;
                    break;
                case 5:
                    I = 5*A;
                    break;
                case 6:
                    I = A;
                    break;
                case 7:
                    I = 3*A;
                    break;
            }
            switch (Q_id){
                case 0:
                    Q = -7*A;
                    break;
                case 1:
                    Q = -5*A;
                    break;
                case 2:
                    Q = -A;
                    break;
                case 3:
                    Q = -3*A;
                    break;
                case 4:
                    Q = 7*A;
                    break;
                case 5:
                    Q = 5*A;
                    break;
                case 6:
                    Q = A;
                    break;
                case 7:
                    Q = 3*A;
                    break;
            }
        }
    }

}
