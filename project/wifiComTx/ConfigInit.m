function [config] = ConfigInit()
    config.sample_rate = 48000;
    config.f1 = 250;
    config.f2 = 750;
    config.sps = 4800*2;          %0.5m: sps = 4800, 
    config.span = 3;
    config.alpha = 0.5;
end

