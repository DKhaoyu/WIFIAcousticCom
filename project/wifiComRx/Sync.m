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
    th1 = 1.6*std(byte_peak);
    th2 = 2*std(byte_peak);
    exist_pos = find(byte_peak>th1);
    exist_pos = [exist_pos;2*exist_pos(size(exist_pos,1))];
    %exist_corr = corr_mat(byte_peak>th,:);
    %[max_val,pos_vote] = max(sum(exist_corr,1));
    start_seq = [];
    frame = 0;
    pilot_size = 0;
    for i=1:size(exist_pos,1)-1
        if(exist_pos(i+1)-exist_pos(i)>1)
            %{
            if byte_peak(exist_pos(i)) > 0.8*byte_peak(exist_pos(i-1))
                start_seq = [start_seq,exist_pos(i)*chirp_len+pos_vote];
            else
                start_seq = [start_seq,(exist_pos(i)-1)*chirp_len+pos_vote];
            end
            %}
            block_1 = play_seq((exist_pos(i-1)-1)*chirp_len+1:exist_pos(i-1)*chirp_len);
            [temp_corr_1,temp_pos_1] = max(1/norm_coef*abs(ifft(fft(block_1).*conj(fft(header)))));
            %temp_corr_1 = max(1/norm_coef*abs(ifft(fft(block).*conj(fft(header)))));
            temp_pos = exist_pos(i)*chirp_len+temp_pos_1;
            block = play_seq(temp_pos-chirp_len+1:temp_pos);
            [temp_corr] = max(1/norm_coef*abs(ifft(fft(block).*conj(fft(header)))));
            if temp_corr > th1
                start_seq = [start_seq,temp_pos];
            else
                start_seq = [start_seq,temp_pos-chirp_len];
            end
        end
    end
    
    pilot_size = 3;
    %{
    temp_pos = (exist_pos(i)+1)*chirp_len+pos_vote;
    temp_corr = 1/norm_coef*sum(header.*play_seq(temp_pos-chirp_len+1:temp_pos));
    if temp_corr > th
        start_seq = [start_seq,temp_pos];
    else
        start_seq = [start_seq,temp_pos-chirp_len];
    end
    %}
    packet_info_size = ceil((round(diff(start_seq)/config.sps)-3-2*pilot_size)/4)-1;
end