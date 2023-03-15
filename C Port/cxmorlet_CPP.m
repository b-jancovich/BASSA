% computes the complex Morlet wavelet for the desired center frequency Fc
% with Nc cycles, with a sampling frequency Fs.
function w = cxmorlet_CPP(Fc, Nc, Fs) %#codegen 
    if (Fc == 0)
        w = [];
    else
        %we want to have the last peak at 2.5 SD
        sd  = (Nc / 2) * abs(1 / Fc) / 2.5;
        wl  = 2 * floor(fix(6 * sd * Fs) / 2) + 1;
        w   = zeros(wl, 1);
        gi  = 0;
        off = fix(wl / 2);

        % declare "w" variable as complex
        w = complex(ones(wl, 1));
        
        for i = 1 : wl
            t       = (i - 1 - off) / Fs;
            w(i)    = bw_cf_CPP(t, sd, Fc);
            gi      = gi + gauss_CPP(t, sd);
        end

        w = w ./ gi;
    end 
return