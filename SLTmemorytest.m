function [mem_required, units] = SLTmemorytest(input, Fs, Fi, Nf, c1, o, mult)

%% Build dummy arrays for wavelets and SLT result
F = linspace(Fi(1), Fi(2), Nf);
order_frac = linspace(o(1), o(2), Nf);
order_int = ceil(order_frac);

% if input is a column vector, turn it into a row vector instead
if (size(input, 2) == 1 && size(input, 1) > 1)
    input = input';
end

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

% the output scalogram
wtresult = zeros(numel(F), Npoints);

%% Compute Array Sizes & Memory Usage

% Find memory required for each array
result_info = whos('wtresult');
wavelets_info = whos('wavelets');
result_mem_bytes = result_info.bytes;
wavelets_mem_bytes = wavelets_info.bytes;

% Memory used for data wrangling in the SLT
data_mem_bytes = result_mem_bytes + wavelets_mem_bytes;

%% Estimate Graphics Rendering Memory Usage

% Get result array dimensions
m = size(wtresult, 1);
n = size(wtresult, 2);

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

% Total Memory Estimate
safetyFactor = 1.2;
BitsTotal = (BitsVertices + BitsColor + BitsWebGL) * safetyFactor;

% Convert bits to bytes
render_bytes = BitsTotal / 8;

%% Total Memory Usage

% Add up totals
mem_bytes = data_mem_bytes + render_bytes;

% Convert to most appropriate units
if mem_bytes < 1000
    mem_required = mem_bytes;
    units = "Bytes";
elseif mem_bytes >= 1000 && mem_bytes < 1e+6
    mem_required = mem_bytes / 1000;
    units = 'KBytes';
elseif mem_bytes >= 1e+6 && mem_bytes < 1e+9
    mem_required = mem_bytes / 1e+6;
    units = 'MBytes';
elseif mem_bytes >= 1e+9 && mem_bytes < 1e+12
    mem_required = mem_bytes / 1e+9;
    units = 'GBytes';
elseif mem_bytes >= 1e+12 && mem_bytes < 1e+15
    mem_required = mem_bytes / 1e+12;
    units = 'TBytes';
end

% computes the complex Morlet wavelet for the desired center frequency Fc
% with Nc cycles, with a sampling frequency Fs.
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