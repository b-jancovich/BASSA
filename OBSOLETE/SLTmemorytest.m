function [mem_required, units] = SLTmemorytest(input, Fs, Fi, Nf, c1, o, ...
    mult, varargin)
%% Build dummy arrays for wavelets and SLT result
F = linspace(Fi(1), Fi(2), Nf);
order_frac = linspace(o(1), o(2), Nf);
order_int = ceil(order_frac);

% if input is a column vector, turn it into a row vector instead
if (size(input, 2) == 1 && size(input, 1) > 1)
    input = input';
end

% find size of signal
[~, Npoints] = size(input);

% the wavelet sets
wavelets = cell(numel(F), max(order_int));

% initialize wavelet sets for either additive or multiplicative
% superresolution
for i_freq = 1 : numel(F)
    if (F(i_freq) == 0)
        wavelets{i_freq, 1} = [];
        continue;
    end
    for i_ord = 1 : order_int(i_freq)
        % compute the number of cycles (additive or multiplicative)
        if (mult ~= 0)
            n_cyc = i_ord * c1;
        else
            n_cyc = i_ord + c1;
        end
        % add the wavelet to the set
        wavelets{i_freq, i_ord} = buildfakewavelets(-F(i_freq), n_cyc, Fs);
    end
end

n_wavelets = size(wavelets, 2);

% the output scalogram
wtresult = zeros(numel(F), Npoints);

%% Compute Memory Usage

% Find memory required for each array
result_info = whos('wtresult');
wavelets_info = whos('wavelets');
input_info = whos('input');

clearvars wavelets input

% Extract memory in bytes from info
mem_bytes_result = result_info.bytes;
mem_bytes_wavelets = wavelets_info.bytes;
mem_bytes_input = input_info.bytes;

% There is actually a result for every wavelet set, not just one.
mem_bytes_result = mem_bytes_result * n_wavelets;

% Working memory estimate (factoring in FFT of input, multiplication with 
% each wavelets, for each frequency:
mem_bytes_wrkng = mem_bytes_input * n_wavelets * Nf * 1.5;

% Total memory used for data storange in calculation of the SLT
mem_bytes_totaldata = mem_bytes_result + mem_bytes_wavelets + mem_bytes_wrkng;

%% Estimate Graphics Rendering Memory Usage

% If time down-sampling is on, & SLT_ncolumns_reduced has been passed in,
if nargin > 7
    Nsamps = varargin{1};
else
    % Nsamps = Nsamps;
end

% Get result array dimensions
m = size(wtresult, 1);
n = size(wtresult, 2);

clearvars wtresult

% Calculate the total number of quads in the surface
NumQuads = (m-1)*(n-1);
            
% Each quad needs 6 vertices to describe the two triangles that compose it.
NumVertices = NumQuads*6;
            
% Each vertex needs three 32 bit floats.
BitsVertices = NumVertices*3*32;

% Assuming the surface has a different color per quad, each vertex will have an additional 24 bit color associated with it
BitsColor = NumVertices * 24;

% Estimate for the additional memory required for 
% webGL rendering (in bits)
BitsWebGL = 4e8; 

% Total Render Memory Estimate
safetyFactor = 1;
BitsTotal = (BitsVertices + BitsColor + BitsWebGL) * safetyFactor;

% Convert bits to bytes
mem_bytes_render = BitsTotal / 8;

%% Total Memory Usage

% Add up totals
mem_bytes_grandtotal = (mem_bytes_totaldata + mem_bytes_render);

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
end

% computes a fake wavelet
function w = buildfakewavelets(Fc, Nc, Fs)
if (Fc == 0)
    w = [];
else
    %we want to have the last peak at 2.5 SD
    sd  = (Nc / 2) * abs(1 / Fc) / 2.5;
    wl  = 2 * floor(fix(6 * sd * Fs) / 2) + 1;
    w   = zeros(wl, 1);
end
return