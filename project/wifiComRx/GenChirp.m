function [header] = GenChirp(config)
    switch config.map_option
        case 0
            chirp_len = 2*config.sps;
            Ts = config.sps/config.sample_rate;
            t0 = 1/config.sample_rate*(0:1:chirp_len-1);
            u0 = (config.f2-config.f1)/(2*Ts);
            header = cos(2*pi*config.f1*t0+pi*u0*t0.*t0);
        case 1
        otherwise
            error("Wrong Mapping Option!")
    end
end
