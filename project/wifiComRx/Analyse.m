function [message_out] = Analyse(play_seq,config)
    header = GenChirp(config);
    [start_pos,packet_info_size] = Sync(header,play_seq,config);
    [message_out] = Decode(play_seq,start_pos,config,packet_info_size);
end

