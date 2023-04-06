duration = 3000;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_3000s_250Hzfs_750,000samps.wav', signal, fs);

duration = 2000;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_2000s_250Hzfs_500,000samps.wav', signal, fs);

duration = 1000;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_1000s_250Hzfs_250,000samps.wav', signal, fs);

duration = 800;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_800s_250Hzfs_200,000samps.wav', signal, fs);

duration = 750;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_750s_250Hzfs_187,500samps.wav', signal, fs);

duration = 500;
fs = 250;
samps = duration * fs;
t = linspace(1, duration, samps);
f0 = 50;
f1 = 100;
sweep = chirp(t, f0, t(end), f1);
noise = rescale(rand(size(sweep)), -0.2, 0.2);
signal = noise+sweep;
signal = signal ./ max(abs(signal));

audiowrite('test_500s_250Hzfs_125,000samps.wav', signal, fs);