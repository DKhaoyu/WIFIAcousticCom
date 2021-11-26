function [dot_seq] = Mapping(config, raw_bit)
    switch config.map_option
%% 16QAM
        case 0
            sym_len = size(raw_bit,2)/4;
            dot_seq = zeros(config.packet_num+sym_len,2);
            info_size_seq = (config.packet_size-config.pilot_size-1)*ones(config.packet_num,1);
            if(config.tail_size>0)
                info_size_seq(config.packet_num) = config.tail_size;
            end
            for i=1:config.packet_num
                for j = 1:2*info_size_seq(i)+1
                    sym_pos = (i-1)*(2*(config.packet_size-config.pilot_size-1)+1)+j;
                    if(j == 1)
                        [I,Q] = QAM(1,info_size_seq(i));
                        dot_seq(sym_pos,1) = I;
                        dot_seq(sym_pos,2) = Q;
                    else
                        bit_start_pos = 4*(sym_pos-i-1)+1;
                        id = 8*raw_bit(bit_start_pos)+4*raw_bit(bit_start_pos+1)+2*raw_bit(bit_start_pos+2)+raw_bit(bit_start_pos+3);
                        [I,Q] = QAM(config.map_option,id);
                        dot_seq(sym_pos,1) = I;
                        dot_seq(sym_pos,2) = Q;
                    end
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