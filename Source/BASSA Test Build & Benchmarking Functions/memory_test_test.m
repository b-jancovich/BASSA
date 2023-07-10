% Memory test script
clear all
close all
clc

% Slt Parameters
durations = linspace(5, 1000, 50);
Fs = 100;
Fi = [1, 49];
Nf = range(Fi);
c1 = 4;
o = [10 40];
mult = 1;
samps = round(durations .* Fs);

% test original memory estimator.
for i = 1:length(samps)
    signal = rand(samps(i), 1);
    [est_mem1(i), units1{i}] = SLTmemorytest(signal, Fs, Fi, Nf, c1, o, mult);
end

% test new memory estimator.
for i = 1:length(samps)
    [est_mem2(i), units2{i}] = SLTmemorytest2(samps(i), Fs, Fi, Nf, c1, o, mult);
end

figure(1)
plot(durations, est_mem1, 'r--')
hold on 
plot(durations, est_mem2, 'b-')
legend('old version', 'new version')
