% Test signal parameters
duration_sweep = 2; % seconds
duration_silence = 0.5; % Seconds
fs = 2000; % Hz
f1 = 100; % Hz
f2 = 800; % Hz
amf1 = 30; % Hz
amf2 = 3; % Hz

% Synthesise test signal
samps_sweep = (duration_sweep*fs);
samps_total = (duration_sweep*fs)+(duration_silence*fs*2);
t_vec_sweep = linspace(1, duration_sweep, samps_sweep);
t_vec_total = linspace(1, duration_sweep+duration_silence, samps_total);
sweep = rescale(chirp(t_vec_sweep, f1, t_vec_sweep(end), f2), -1, 1);
modulator = rescale(sign(chirp(t_vec_sweep, amf1, t_vec_sweep(end),...
    amf2, [], -90)), 0, 1);
noisy = rescale(rand(1, samps_total), -0.1, 0.1);
silence = zeros(1, fs*duration_silence);
testsig = noisy + [silence, (sweep .* modulator), silence];

% Superlet Parameters
Fi = [1, (fs/2)-1];
fres = 1;
c1 = 4;
o = [10, 40];
mult = 0.5;
Nf = range(Fi)/fres;
f_vec = linspace(Fi(1), Fi(2), Nf);

% Begin Profiling
profile on

% Run native implementaion of faslt analysis
SLT = nfaslt(testsig, fs, Fi, Nf, c1, o, mult);

% Run MEX implementation of faslt analysis
SLT_mex = faslt_mex(testsig, fs, Fi, Nf, c1, o, mult);

% profile off
p = profile('info');

% Check Error between methods
error = rmse(SLT, SLT_mex, 'all');

% Print profiling results
native_linenum = find(strcmp({p.FunctionTable.FunctionName}, 'nfaslt'));
mex_linenum = find(strcmp({p.FunctionTable.FunctionName}, 'faslt_mex'));
disp('Total time, Native MATLAB: ')
disp(p.FunctionTable(native_linenum).TotalTime)
disp('Total time, MEX: ')
disp(p.FunctionTable(mex_linenum).TotalTime)

% Plot results
figure(1)
tiledlayout(1, 2)
nexttile
s1 = pcolor(t_vec_total, f_vec, SLT);
s1.EdgeColor = 'none';
title('Native MATLAB "nfaslt.m"')
nexttile
s2 = pcolor(t_vec_total, f_vec, SLT_mex);
s2.EdgeColor = 'none';
title('Native MATLAB "faslt_mex.mexw64"')