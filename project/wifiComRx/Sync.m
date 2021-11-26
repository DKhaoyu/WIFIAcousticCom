function [start_seq,packet_info_size] = Sync(header,play_seq,config)
    play_seq = play_seq.';
    norm_coef = sum(header.*header);
    chirp_len = size(header,2);
    block_num = floor(size(play_seq,2)/chirp_len);
    corr_mat = zeros(block_num,chirp_len);
    for i = 1:block_num
        block = play_seq((i-1)*chirp_len+1:i*chirp_len);
        corr_mat(i,:) = 1/norm_coef*ifft(fft(block).*conj(fft(header)));
    end
    byte_peak = max(abs(corr_mat),[],2);
    th = 1.5*std(byte_peak);
    exist_pos = find(byte_peak>th);
    exist_corr = corr_mat(byte_peak>th,:);
    [max_val,pos_vote] = max(sum(exist_corr,1));
    start_seq = [];
    for i=1:size(exist_pos,1)-1
        if(exist_pos(i+1)-exist_pos(i)>1)
            if byte_peak(exist_pos(i)) > 0.8*byte_peak(exist_pos(i-1))
                start_seq = [start_seq,exist_pos(i)*chirp_len+pos_vote];
            else
                start_seq = [start_seq,(exist_pos(i)-1)*chirp_len+pos_vote];
            end
        end
    end
    if byte_peak(exist_pos(i+1))> 0.8*0.8*byte_peak(exist_pos(i))
        start_seq = [start_seq,((exist_pos(i)+1)*chirp_len+pos_vote)];
    else
        start_seq = [start_seq,(exist_pos(i)*chirp_len+pos_vote)];
    end
    pilot_size = ceil(size(exist_corr,1)/size(start_seq,2));
    packet_info_size = floor(diff(start_seq)/config.sps/2)-3-pilot_size;
end