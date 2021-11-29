function [play_seq, config, header] = EncodeModule(text,config)
%% encoder parameter initialize
    byte_len = size(text,2);
    raw_bytes = reshape(de2bi(abs(text),8,'left-msb').',1,8*byte_len);
    encode_bit = Hamming84(raw_bytes);
    % raw_bit = reshape(de2bi(abs(text),'left-msb',8).',1,8*byte_len);
    config.packet_num = ceil(byte_len/(config.packet_size-config.pilot_size-1));
    config.tail_size = mod(byte_len,config.packet_size-config.pilot_size-1);
    config.Ts = config.sps/config.sample_rate;
%% mapping
    [dot_seq] = Mapping(config, encode_bit);
%% genHeader
    [header] = GenHeader(config);
%% assmeble packet
    [play_seq] = Assemble(config,header,dot_seq);
    play_seq = play_seq/max(abs(play_seq));
    warm_up = sin(2*pi*config.frequency*1/config.sample_rate*(0:1:0.5*config.sample_rate));
    play_seq = [warm_up,play_seq];
    sound(play_seq,config.sample_rate);
    figure;
    plot(1/config.sample_rate*(0:1:size(play_seq,2)-1),play_seq);
    %filename = strcat(datestr(datetime,'yyyy-mm-dd HH-MM-SS'),'.wav');
    %audiowrite(filename,play_seq,config.sample_rate);
end

