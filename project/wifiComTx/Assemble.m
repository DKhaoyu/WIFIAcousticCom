function [play_seq] = Assemble(config,header,dot_seq)
   switch config.map_option
        case 0
            %full_packet_sample = config.pilot_size*2*config.sps+2*config.sps+(config.packet_size-config.pilot_size-1)*2*config.sps;
            %packet_sample_seq = (((config.packet_size-config.pilot_size-1)*2+config.span)*config.sps+1)*ones(1,config.packet_num);
            %packet_symbol_num_seq = 2*(config.packet_size-config.pilot_size-1)*ones(1,config.packet_num);
            %tail_packet_sample = config.pilot_size*2*config.sps+2*config.sps+(config.tail_size*2+config.span)*config.sps+1;
            silent_sym = 3;
            silent_period = 0;
            period_sample = config.sample_rate/config.frequency;
            transition_period = 20;
            full_packet_sample = (config.pilot_size)*2*config.sps+(config.packet_size-config.pilot_size)*4*config.sps+silent_sym*config.sps;
            %packet_sample_seq = 2*(config.packet_size-config.pilot_size-1)*config.sps*ones(1,config.packet_num);
            packet_symbol_num_seq = 4*(config.packet_size-config.pilot_size-1)*ones(1,config.packet_num);
            tail_packet_sample = (config.pilot_size)*2*config.sps+(config.tail_size+1)*4*config.sps+silent_sym*config.sps;
            if(config.tail_size>0)
                %packet_sample_seq(config.packet_num) = config.tail_size*2*config.sps;
                packet_symbol_num_seq(config.packet_num) = 4*config.tail_size;
                play_seq = zeros(1,full_packet_sample*(config.packet_num-1)+tail_packet_sample);
            else
                play_seq = zeros(1,full_packet_sample*config.packet_num);
            end
            %window = [zeros(silent_period*period_sample,1);hann(config.sps-2*silent_period*period_sample);zeros(silent_period*period_sample,1)].';
            %window = [zeros(silent_period*period_sample,1);ones(config.sps-2*silent_period*period_sample,1);zeros(silent_period*period_sample,1)].';
            window = TrapezoidWondow(config,silent_period,transition_period);
            t_sym = 1/config.sample_rate*(0:1:config.sps-1);
            sym_id = 1;
            for i=1:config.packet_num
                play_seq((i-1)*full_packet_sample+1:(i-1)*full_packet_sample+config.pilot_size*2*config.sps) = header;
                %sym_id = (i-1)*(2*(config.packet_size-config.pilot_size-1)+1)+1;
                start_sample = (i-1)*full_packet_sample+(config.pilot_size)*2*config.sps+silent_sym*config.sps+1;
                play_seq(start_sample:start_sample+config.sps-1) = sin(2*pi*config.frequency*t_sym).*window;
                start_sample = start_sample+config.sps;
                for j = 1:4
                    play_seq(start_sample:start_sample+config.sps-1) = (dot_seq(sym_id,1)*cos(2*pi*config.frequency*t_sym)-dot_seq(sym_id,2)*sin(2*pi*config.frequency*t_sym)).*window;
                    sym_id = sym_id + 1;
                    start_sample = start_sample+config.sps;
                end
                sym_len = packet_symbol_num_seq(i);
                %info_I = zeros(1,sym_len*config.sps);
                %info_Q = zeros(1,sym_len*config.sps);
                for j = 1:sym_len
                    %sym_id = 2*(i-1)*(config.packet_size-config.pilot_size-1)+i+j;
                    %start_sample = (i-1)*full_packet_sample+(config.pilot_size+silent_sym)*2*config.sps+config.sps+1+j*config.sps;
                    play_seq(start_sample:start_sample+config.sps-1) = (dot_seq(sym_id,1)*cos(2*pi*config.frequency*t_sym)-dot_seq(sym_id,2)*sin(2*pi*config.frequency*t_sym)).*window;
                    sym_id = sym_id + 1;
                    start_sample = start_sample+config.sps;
                end
            end
       case 1
           play_seq = [];
       otherwise
           error("Wrong Mapping Option!");
   end
end

function [window] = TrapezoidWondow(config,silent_period,transition_period)
    period_sample = config.sample_rate/config.frequency;
    lh_transition = 1/(transition_period*period_sample)*(0:transition_period*period_sample-1);
    hl_transition = fliplr(lh_transition);
    window = [zeros(silent_period*period_sample,1);lh_transition.';ones(config.sps-2*(silent_period+transition_period)*period_sample,1);hl_transition.';zeros(silent_period*period_sample,1)].';
end