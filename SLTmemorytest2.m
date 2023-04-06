function [mem_required, units] = SLTmemorytest2(Nsamps, Fs, Fi, Nf, c1, o, mult, varargin)

% build frequency vector
F = linspace(Fi(1), Fi(2), Nf);

% Initialize the order used at each frequency. 
order_frac = linspace(o(1), o(2), Nf);
order_int = ceil(order_frac);

% Cell array of wavelet sets
wavelet_lengths = cell(numel(F), max(order_int));
        
% initialize wavelet sets for either additive or multiplicative
% superresolution
for i_freq = 1 : numel(F)    
    for i_ord = 1 : order_int(i_freq)
        
        % compute the number of cycles (additive or multiplicative)
        if (mult ~= 0)
            n_cyc = i_ord * c1;
        else
            n_cyc = i_ord + c1;
        end
        
        % Add the length of the curent wavelet to the set, but don't
        % actually build it.
        wavelet_lengths{i_freq, i_ord} = dummymorlet(-F(i_freq), n_cyc, Fs);
    end
end

% Estimate memory of convolution operations
mem_bytes_conv = 0;
for i_freq = 1 : numel(F)
    % get the number of integer wavelets
    Nwavelets = floor(order_frac(i_freq));
    % Do the convolution mem estimate
    for i_ord = 1 : Nwavelets      
        mem_bytes_conv_single = estimate_conv_memory(Nsamps, wavelet_lengths{i_freq, i_ord});
    end
    mem_bytes_conv = mem_bytes_conv + mem_bytes_conv_single;
end

% Compute the total number of elements comprising all the wavelets & 
% multiply by 8 bytes (mem size of one element of type "double")
mem_bytes_wavelets = sum([wavelet_lengths{:,:}], 'all') * 8;

% compute the size of the conv results before Geometric Mean
result_elems = Nf * Nsamps;
mem_bytes_result = result_elems * Nwavelets * 8;

% Working memory estimate (factoring in FFT of input, multiplication with 
% each wavelets, for each frequency:
mem_bytes_input = Nsamps * 8;
mem_bytes_wrkng = mem_bytes_input * Nwavelets * Nf * 1.5;

%% Estimate Rendering Memory

% If time down-sampling is on, & SLT_ncolumns_reduced has been passed in,
if nargin > 7
    Nsamps = varargin{1};
else
    % Nsamps = Nsamps;
end

% Calculate the total number of quads in the surface
NumQuads = (Nf-1) * (Nsamps-1);
            
% Each quad needs 6 vertices to describe the two triangles that compose it.
NumVertices = NumQuads * 6;
            
% Each vertex needs three 32 bit floats.
BitsVertices = NumVertices * 3 * 32;

% Assuming the surface has a different color per quad, each vertex will have an additional 24 bit color associated with it
BitsColor = NumVertices * 24;

% Estimate for the additional memory required for 
% webGL rendering (in bits)
BitsWebGL = 4e8; 

% Total Render Memory Estimate
BitsTotal = (BitsVertices + BitsColor + BitsWebGL);

% Convert bits to bytes
mem_bytes_render = BitsTotal / 8;

%% Total Memory Usage

% Sum of memory used by each process
mem_bytes_grandtotal = (mem_bytes_conv + mem_bytes_result + ...
    mem_bytes_wavelets + mem_bytes_render + mem_bytes_wrkng);

% Convert to most appropriate units
if mem_bytes_grandtotal < 1000
    mem_required = mem_bytes_grandtotal;
    units = "Bytes";
elseif mem_bytes_grandtotal >= 1000 && mem_bytes_grandtotal < 1e+6
    mem_required = mem_bytes_grandtotal / 1000;
    units = 'KBytes';
elseif mem_bytes_grandtotal >= 1e+6 && mem_bytes_grandtotal < 1e+9
    mem_required = mem_bytes_grandtotal / 1e+6;
    units = 'MBytes';
elseif mem_bytes_grandtotal >= 1e+9 && mem_bytes_grandtotal < 1e+12
    mem_required = mem_bytes_grandtotal / 1e+9;
    units = 'GBytes';
elseif mem_bytes_grandtotal >= 1e+12 && mem_bytes_grandtotal < 1e+15
    mem_required = mem_bytes_grandtotal / 1e+12;
    units = 'TBytes';
elseif mem_bytes_grandtotal >= 1e+15 && mem_bytes_grandtotal < 1e+18
    mem_required = mem_bytes_grandtotal / 1e+12;
    units = 'PBytes';
end

return

% Compute the length of the wavelet
function wl = dummymorlet(Fc, Nc, Fs)
    if (Fc == 0)
        wl = 0;
    else
        %we want to have the last peak at 2.5 SD
        sd  = (Nc / 2) * abs(1 / Fc) / 2.5;
        wl  = 2 * floor(fix(6 * sd * Fs) / 2) + 1;
    end
return

function conv_mem = estimate_conv_memory(a_length, b_length)
% Estimate the memory consumption of the convolution of input vectors of 
% length "a_length" and "b_length".

% multiply by 8 bytes because data is always of type "double"
size_a = a_length * 8;
size_b = b_length * 8;
size_conv_ab = (a_length + b_length - 1) * 8;
conv_mem = size_a + size_b + size_conv_ab;
return
