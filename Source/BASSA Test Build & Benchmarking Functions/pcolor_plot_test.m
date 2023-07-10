clear 
close 
clc
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

% Run MEX implementation of faslt analysis
SLT = faslt_mex(testsig, fs, Fi, Nf, c1, o, mult);

% % Convert power to dB W
SLT = 10*log10(SLT); 

% function sltplot(t_vec, f_vec, SLT)
hfig = figure;
Uifigure.handlevisibility = 'on';
ax = gca;
s = pcolor(ax, t_vec_total, f_vec, SLT);
s.EdgeColor = 'none';
grid on
ylabel('Frequency (Hz)');
xlabel('Time (s)');
xticks('auto')
ax.Layer = 'top';
ax.GridColor = [1 1 1];
ax.GridAlpha = 0.2;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.MinorGridLineStyle = ':';
ax.MinorGridColor = [1 1 1];
ax.MinorGridAlpha = 0.17;
c = colorbar;
% Dynamically Set:
xlim(freqlim)
ylim(timelim)
title(filename)
c.Label.String = magnitude_unit;
