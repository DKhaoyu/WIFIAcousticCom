function [decode_str] = Decode(play_seq,start_pos,config,packet_info_size)
    decode_str = "";
    symbol_sample = config.sps;
    period_sample = floor(config.sample_rate/config.frequency);
    N_drop = 15;
    silent_sym = 2;
    silent_period = 0;
    byte_sample = 4*symbol_sample;
    %window = hann(symbol_sample-2*period_sample*silent_period);
    %window = window(period_sample*N_drop+1:config.sps-period_sample*N_drop-2*period_sample*silent_period);
    for i = 1:size(start_pos,2)
        pos = start_pos(i);
        est_symbol = play_seq(pos+silent_sym*symbol_sample:pos+(silent_sym+1)*symbol_sample-1);
        est_symbol = est_symbol(silent_period*period_sample+1:symbol_sample-silent_period*period_sample);
        %[attenuation] = ChannelEstimation(est_symbol, config, N_drop, period_sample, window);
        attenuation = ChannelEstimation(est_symbol);
        [time_bias] = SyncModify(est_symbol,period_sample,config,N_drop);
        pos_modify = pos + time_bias;
        if i == size(start_pos,2)
            %size_symbol = play_seq(pos_modify+(silent_sym+1)*symbol_sample:pos_modify+(silent_sym+2)*symbol_sample-1);
            %size_symbol = size_symbol(silent_period*period_sample+1:symbol_sample-silent_period*period_sample);
            %[I,Q] = Demodualte(size_symbol,config,N_drop,period_sample);
            %[bit_seq] = Demapping(I,Q,attenuation,1);
            %packet_size = bit_seq*[32,16,8,4,2,1].';
            %packet_size = min(packet_size, packet_info_size(1));
            size_byte = play_seq(pos_modify+(silent_sym+1)*symbol_sample:pos_modify+(silent_sym+1)*symbol_sample+byte_sample-1);
            packet_size = HammingDecode(size_byte,config,N_drop,period_sample,1,attenuation);
        else
            packet_size = packet_info_size(i);
        end
        byte_start_pos = pos_modify+(silent_sym+1)*symbol_sample+byte_sample;
        for byte_id = 1:packet_size
            %symbol_1 = play_seq(byte_start_pos+(byte_id-1)*2*symbol_sample:byte_start_pos+(byte_id-1)*2*symbol_sample+symbol_sample-1);
            %symbol_1 = symbol_1(silent_period*period_sample+1:symbol_sample-silent_period*period_sample);
            %symbol_2 = play_seq(byte_start_pos+(byte_id-1)*2*symbol_sample+symbol_sample:byte_start_pos+(byte_id-1)*2*symbol_sample+2*symbol_sample-1);
            %symbol_2 = symbol_2(silent_period*period_sample+1:symbol_sample-silent_period*period_sample);
            %[I1,Q1] = Demodualte(symbol_1,config,N_drop,period_sample);
            %[I2,Q2] = Demodualte(symbol_2,config,N_drop,period_sample);
            %[bit_seq1] = Demapping(I1,Q1,attenuation,config.map_option);
            %[bit_seq2] = Demapping(I2,Q2,attenuation,config.map_option);
            %bit_seq = [bit_seq1,bit_seq2];
            %id = bit_seq*[0,64,32,16,8,4,2,1].';
            id = HammingDecode(play_seq(byte_start_pos:byte_start_pos+byte_sample-1),config,N_drop,period_sample,0,attenuation);
            if id == 32
                decode_str = strcat(decode_str," ");
            else
                decode_str = strcat(decode_str,char(id));
            end
            byte_start_pos = byte_start_pos + byte_sample;
        end
    end
end

function [id] = HammingDecode(byte_wave,config,N_drop,period_sample,flag,attenuation)
    I = zeros(1,4);
    Q = zeros(1,4);
    bit_seq = zeros(1,16);
    decode_byte = zeros(1,8);
    H = [1,1,1,0,1,0,0,0;1,1,0,1,0,1,0,0;1,0,1,1,0,0,1,0;0,1,1,1,0,0,0,1];
    for ii = 1:4
        [I(ii),Q(ii)] = Demodulate(byte_wave((ii-1)*config.sps+1:ii*config.sps),config,N_drop,period_sample);
        bit_seq((ii-1)*4+1:ii*4) = Demapping(I(ii),Q(ii),attenuation,config.map_option);
    end
    for ii = 1:2
        error_map = mod(bit_seq((ii-1)*8+1:ii*8)*H.',2);
        for v = 1:8
            if(all(error_map == H(v,:)))
                bit_seq((ii-1)*8+v) = 1-bit_seq((ii-1)*8+v);
                break;
            end
        end
        decode_byte((ii-1)*4+1:ii*4) = bit_seq((ii-1)*8+1:(ii-1)*8+4);
    end
    if flag
        id = bi2de(decode_byte(3:8),'left-msb');
    else
        id = bi2de(decode_byte,'left-msb');
    end
end

function [attenuation] = ChannelEstimation(pilot_symbol)
    %sym_len = size(pilot_symbol,1);
    %symbol_cal = pilot_symbol(period_sample*N_drop+1:sym_len-period_sample*N_drop)./window;
    %cal_len = sym_len-2*period_sample*N_drop;
    %attenuation = sqrt(2*sum(symbol_cal.*symbol_cal)/cal_len);
    attenuation = (max(pilot_symbol)-min(pilot_symbol))/2;
end

function [time_bias] = SyncModify(est_symbol,period_sample,config,N_drop)
    [I,Q] = Demodualte(est_symbol,config,N_drop,period_sample);
    phase = angle(I+1j*Q);
    time_bias = round((-pi/2-phase)/(2*pi)*period_sample);
end
function [I,Q] = Demodualte(symbol_seq,config,N_drop,period_sample)
    sym_len = size(symbol_seq,1);
    enve = abs(hilbert(symbol_seq));
    enve = enve(period_sample*N_drop+1:sym_len-period_sample*N_drop);
    enve = enve/max(enve);
    symbol_cal = symbol_seq(period_sample*N_drop+1:sym_len-period_sample*N_drop)./enve;
    cal_len = sym_len-2*period_sample*N_drop;
    t = 1/config.sample_rate*(0:1:cal_len-1);
    carrier_sin = sin(2*pi*config.frequency*t);
    carrier_cos = cos(2*pi*config.frequency*t);
    I = 2/cal_len*sum(symbol_cal.'.*carrier_cos);
    Q = -2/cal_len*sum(symbol_cal.'.*carrier_sin);
end

function [bit_seq] = Demapping(I,Q,attenuation,map_option)
    switch map_option
        case 0
            A = 0.2357;
            A_norm = A*attenuation;
            if I<-2*A_norm
                I_norm = -3*A;
            elseif -2*A_norm<I&&I<0
                I_norm = -A;
            elseif 0<I&&I<2*A_norm
                I_norm = A;
            else
                I_norm = 3*A;
            end
            if Q<-2*A_norm
                Q_norm = -3*A;
            elseif -2*A_norm<Q&&Q<0
                Q_norm = -A;
            elseif 0<Q&&Q<2*A_norm
                Q_norm = A;
            else
                Q_norm = 3*A;
            end
            switch I_norm
                case -3*A
                    I_id = [0,0];
                case -A
                    I_id = [0,1];
                case A
                    I_id = [1,1];
                otherwise
                    I_id = [1,0];
            end
            switch Q_norm
                case -3*A
                    Q_id = [0,0];
                case -A
                    Q_id = [0,1];
                case A
                    Q_id = [1,1];
                otherwise
                    Q_id = [1,0];
            end
            bit_seq = [Q_id,I_id];
        otherwise
            A = 0.101;
            A_norm = A*attenuation;
            if I<-6*A_norm
                I_norm = -7*A;
            elseif -6*A_norm<I&&I<-4*A_norm
                I_norm = -5*A;
            elseif -4*A_norm<I&&I<-2*A_norm
                I_norm = -3*A;
            elseif -2*A_norm<I&&I<0
                I_norm = -A;
            elseif 0<I&&I<2*A_norm
                I_norm = A;
            elseif 2*A_norm<I&&I<4*A_norm
                I_norm = 3*A;
            elseif 4*A_norm<I&&I<6*A_norm
                I_norm = 5*A;
            else
                I_norm = 7*A;
            end
            if Q<-6*A_norm
                Q_norm = -7*A;
            elseif -6*A_norm<Q&&Q<-4*A_norm
                Q_norm = -5*A;
            elseif -4*A_norm<Q&&Q<-2*A_norm
                Q_norm = -3*A;
            elseif -2*A_norm<Q&&Q<0
                Q_norm = -A;
            elseif 0<Q&&Q<2*A_norm
                Q_norm = A;
            elseif 2*A_norm<Q&&Q<4*A_norm
                Q_norm = 3*A;
            elseif 4*A_norm<Q&&Q<6*A_norm
                Q_norm = 5*A;
            else
                Q_norm = 7*A;
            end
            switch I_norm
                case -7*A
                    I_id = [0,0,0];
                case -5*A
                    I_id = [0,0,1];
                case -3*A
                    I_id = [0,1,1];
                case -A
                    I_id = [0,1,0];
                case A
                    I_id = [1,1,0];
                case 3*A
                    I_id = [1,1,1];
                case 5*A
                    I_id = [1,0,1];
                otherwise
                    I_id = [1,0,0];
            end
            switch Q_norm
                case -7*A
                    Q_id = [0,0,0];
                case -5*A
                    Q_id = [0,0,1];
                case -3*A
                    Q_id = [0,1,1];
                case -A
                    Q_id = [0,1,0];
                case A
                    Q_id = [1,1,0];
                case 3*A
                    Q_id = [1,1,1];
                case 5*A
                    Q_id = [1,0,1];
                otherwise
                    Q_id = [1,0,0];
            end
            bit_seq = [Q_id,I_id];
    end
end
