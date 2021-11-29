function [config] = ConfigInit()
    config.sample_rate = 48000;
    config.f1 = 750;
    config.f2 = 1200;
    config.sps = 4800;          %0.5m: sps = 4800, 
    config.span = 3;
    config.alpha = 0.5;
end

