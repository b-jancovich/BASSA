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

% Run MEX implementation of faslt analysis
SLT = faslt_mex(testsig, fs, Fi, Nf, c1, o, mult);

% Convert power to dB W
SLT = 10*log10(SLT); 

% plot with Surf()
figure(1)
surf(f_vec, t_vec, SLT', EdgeColor = 'none', FaceColor='texturemap')
set(gca, XDir="reverse", View=[90 90])

% % Plot with Pcolor()
figure(2)
s = pcolor(t_vec, f_vec, SLT);
s.EdgeColor = 'none';

% Plot with Contourf()
figure(3)
levels = 30;
contourf(t_vec, f_vec, SLT, levels, EdgeColor="none")

profile off
p = profile('info');

% Profiler results, sorted by descending time
% Function - Time (Total, Seconds) -  Number of calls
% 'faslt_mex_plot_profiler'	123.351620199721	1
% 'faslt_mex'	122.316672697206	1
% 'contourf'	0.385698400937174	1
% 'contourobjHelper'	0.355138700862920	1
% 'contourobjHelper>localParseargs'	0.354839900862194	1
% 'surf'	0.0955734002322253	1
% 'newplot'	0.0739711001797358	3
% 'xyzcheck'	0.0428957001042284	1
% 'CanvasPlugin.CanvasPlugin>CanvasPlugin.createCanvas'	0.0360056000874868	3
% 'CanvasSetup>CanvasSetup.createScribeLayers'	0.0233202000566637	3
% 'ScribeStackManager.ScribeStackManager>ScribeStackManager.getLayer'	0.0225795000548639	12
% 'pcolor'	0.0214588000521408	1
% 'ScribeStackManager.ScribeStackManager>ScribeStackManager.createLayer'	0.0186871000454061	9
% 'Contour.Contour>Contour.Contour'	0.0152038000369424	1