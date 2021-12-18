function [dot_seq] = Mapping(config, raw_bit)
    switch config.map_option
%% 16QAM
        case 0
            sym_len = size(raw_bit,2)/4;
            dot_seq = zeros(4*config.packet_num+sym_len,2);
            info_size_seq = (config.packet_size-config.pilot_size-1)*ones(config.packet_num,1);
            if(config.tail_size>0)
                info_size_seq(config.packet_num) = config.tail_size;
            end
            sym_pos = 1;
            for i=1:config.packet_num
                length_bit = de2bi(info_size_seq(i),8,'left-msb');
                encode_length_bit = zeros(1,16);
                encode_length_bit(1:8) = Hamming84(length_bit(1:4));
                encode_length_bit(9:16) = Hamming84(length_bit(5:8));
                for j = 1:4
                    id = bi2de(encode_length_bit((j-1)*4+1:4*j),'left-msb');
                    [I,Q] = QAM(0,id);
                    dot_seq(sym_pos,1) = I;
                    dot_seq(sym_pos,2) = Q;
                    sym_pos = sym_pos + 1;
                end
                for j = 1:4*info_size_seq(i)
                    %sym_pos = (i-1)*(4*(config.packet_size-config.pilot_size))+j;
                    bit_start_pos = 4*(sym_pos-4*i-1)+1;
                    %id = 8*raw_bit(bit_start_pos)+4*raw_bit(bit_start_pos+1)+2*raw_bit(bit_start_pos+2)+raw_bit(bit_start_pos+3);
                    id = bi2de(raw_bit(bit_start_pos:bit_start_pos+3),'left-msb');
                    [I,Q] = QAM(config.map_option,id);
                    dot_seq(sym_pos,1) = I;
                    dot_seq(sym_pos,2) = Q;
                    sym_pos = sym_pos+1;
                end
            end
%% 64QAM
        case 1
            
        otherwise
    end
end

function [I,Q] = QAM(map_option, id)
    switch map_option
        case 0
            A = 0.2357;
            I_id = mod(id,4);
            Q_id = floor(id/4);
            switch I_id
                case 0
                    I = -3*A;
                case 1
                    I = -A;
                case 2
                    I = 3*A;
                case 3
                    I = A;
                otherwise
                    error("Wrong Mapping for 16QAM");
            end
            switch Q_id
                case 0
                    Q = -3*A;
                case 1
                    Q = -A;
                case 2
                    Q = 3*A;
                case 3
                    Q = A;
                otherwise
                    error("Wrong Mapping for 16QAM");
            end
            if abs(Q)+abs(I)==4*A
                I = 0.8*I;
                Q = 0.8*Q;
            end
        case 1
            A = 0.101;
            I_id = mod(id,8);
            Q_id = floor(id/8);
            switch I_id
                case 0
                    I = -7*A;
                case 1
                    I = -5*A;
                case 2
                    I = -A;
                case 3
                    I = -3*A;
                case 4
                    I = 7*A;
                case 5
                    I = 5*A;
                case 6
                    I = A;
                case 7
                    I = 3*A;
                otherwise
                    error("Wrong Mapping for 64QAM!");
            end
            switch Q_id
                case 0
                    Q = -7*A;
                case 1
                    Q = -5*A;
                case 2
                    Q = -A;
                case 3
                    Q = -3*A;
                case 4
                    Q = 7*A;
                case 5
                    Q = 5*A;
                case 6
                    Q = A;
                case 7
                    Q = 3*A;
                otherwise
                    error("Wrong Mapping for 64QAM!");
            end
        otherwise
            error("Wrong Mapping Option!")
    end
end