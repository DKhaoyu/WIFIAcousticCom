function [encode_bits] = Hamming84(info_bytes)
    G = [1,0,0,0,1,1,1,0;0,1,0,0,1,1,0,1;0,0,1,0,1,0,1,1;0,0,0,1,0,1,1,1];
    block_num = size(info_bytes,2)/4;
    for ii = 1:block_num
        encode_bits(8*(ii-1)+1:8*ii) = mod(info_bytes(4*(ii-1)+1:4*ii)*G,2);
    end
end

