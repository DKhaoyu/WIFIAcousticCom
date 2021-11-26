function [header] = GenHeader(config)
    switch config.map_option
        case 0
            chirp_len = 2*config.sps;
            t0 = 1/config.sample_rate*(0:1:chirp_len-1);
            u0 = (config.f2-config.f1)/(2*config.Ts);
            t = repmat(t0,[1,config.pilot_size]);
            header = cos(2*pi*config.f1*t+pi*u0*t.*t);
        case 1
        otherwise
            error("Wrong Mapping Option!")
    end
end

