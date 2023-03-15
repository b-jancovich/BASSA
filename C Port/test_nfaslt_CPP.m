% Algorithm parameters
Fs = 500;                   % Sampling Frequency of "signal" (Hz, Scalar, INT)
f_min = 20;                 % Lowest frequency of interest (Hz, Scalar, INT)
f_max = Fs/2;                % Highest frequency of interest (Hz, Scalar, INT)
f_res = 1;                  % Target frequency resolution (Hz, Scalar, FLOAT)
c1 = 4;                     % Initial number of cycles in superlet (Scalar, INT)
o = [10 40];                % Interval of superresolution orders (1x2, INT)
mult = 1;                   % Additive (0) or Multiplicative (1) Super-Resolution (Scalar, LOGICAL)

Fi = [f_min, f_max];        % Frequency interval
Nf = range(Fi) / f_res;     % Number of frequency points to evaluate

% Test signal 
f0 = 50;                                    % Test signal start freq
f1 = 150;                                   % Test signal end freq
d = 8;                                      % Duration of test signal (s)

t = 0:(1/Fs):d;                             % Test signal time vector
s = chirp(t, f0, t(end), f1)';              % Chirp part of test signal
n = rescale(rand(length(t), 1), -0.2, 0.2); % Noise part of test signal
input = s + n;                              % Test signal

% Declare wtresult as complex matrix
wtresult = complex(zeros(Nf, length(t)));

% Compute Superlet Transform
wtresult = nfaslt_CPP(input, Fs, Fi, Nf, c1, o, mult);
