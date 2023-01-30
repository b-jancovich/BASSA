clear
close all
clc
% This script is the backend for a GUI-based tool that loads an audio 
% file and performs time frequency analysis via four different methods, 
% and then compares the results. The algorithm for Superlet Transform, 
% implemented using the function 'nfaslt.m", was developed by
% Mocal et al. (2021), and released under MIT licence by the 
% Transylvanian Institute Of Neuroscience.
%
% Ben Jancovich, 2022
% University of New South Wales
% This work is licensed under the Creative Commons Attribution 4.0 
% International License. To view a copy of this license, visit 
% http://creativecommons.org/licenses/by/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
%
%% Init home directory
if ispc
  home = getenv('USERPROFILE');
else
  home = getenv('HOME');
end

%% User Interaction: Load audio file
uiwait(msgbox('Please select a .wav file to analyse...'));
[file, path] = uigetfile('.wav', 'Load WAV file:', home);
[signal, original_fs] = audioread(fullfile(path, file));

%% Strip Excess Channels

% Ensure signal is mono:
if size(signal, 2) == 1
    % DO NOTHING
elseif size(signal, 2) ~= 1
    % If it isn't, use channel 1
    signal = signal(:, 1);
    warning('This script only supports mono audio files. Analysis proceeding on channel 1 only...')
end

%% User Interaction: Trim Audio

% vectors and counts
samps = length(signal);
duration = samps / original_fs;
t = linspace(0, duration, samps);

% Dialog
trim = questdlg(['The selected file is ', num2str(duration), ' seconds long.', newline,...
    'Do you want to trim the audio file?', newline, ...
    'Audio files longer than 1 minute may take a long time to analyse.'],...
    'Trim Audio?', 'Yes', 'No', 'No');

switch trim
    case 'Yes'
        % Plot time domain signal
        t_start_init = num2str(t(1));
        t_end_init = num2str(t(end));
        figure(1)
        plot(t, signal)
        xlabel('Time (seconds)')
        ylabel('Amplitude (arb)')
        title('Original Time Domain Signal', 'FontWeight', 'bold')
        set(gcf, 'Position', [100 100 700 450])

        % Set new Start and End times via UI Dialog
        prompt = {'Enter new start time (seconds):',...
            'Enter new end time (seconnds):'};
        dlgtitle = 'Enter new start & end times';
        dims = [1 50];
        definput = {t_start_init, t_end_init};
        trim_params = inputdlg(prompt,dlgtitle,dims,definput);

        % Handle Invalid Entries
        if str2double(trim_params{1}) < t(1) || str2double(trim_params{1}) > t(end)
            uiwait(msgbox('Error: Invalid Start Time'));
            prompt = {'Enter new start time (seconds):',...
                'Enter new end time (seconnds):'};
            dlgtitle = 'Enter new start & end times';
            dims = [1 50];
            definput = {t_start_init, t_end_init};
            trim_params = inputdlg(prompt,dlgtitle,dims,definput);
        elseif str2double(trim_params{2}) < t(1) || str2double(trim_params{2}) > t(end)
            uiwait(msgbox('Error: Invalid End Time'));
            prompt = {'Enter new start time (seconds):',...
                'Enter new end time (seconnds):'};
            dlgtitle = 'Enter new start & end times';
            dims = [1 50];
            definput = {t_start_init, t_end_init};
            trim_params = inputdlg(prompt,dlgtitle,dims,definput);
        elseif str2double(trim_params{1}) > str2double(trim_params{2})
            uiwait(msgbox('Error: Start Time Must Be Smaller Than End Time'));
            prompt = {'Enter new start time (seconds):',...
                'Enter new end time (seconnds):'};
            dlgtitle = 'Enter new start & end times';
            dims = [1 50];
            definput = {t_start_init, t_end_init};
            trim_params = inputdlg(prompt,dlgtitle,dims,definput);
        end

        % Extract Params
        t_start = str2double(trim_params(1));
        t_end = str2double(trim_params(2));

        % Trim signal
        [~,start_idx] = min(abs(t - t_start));
        [~,end_idx] = min(abs(t - t_end));
        trimmed_sig = signal(start_idx:end_idx);
        trimmed_samps = length(trimmed_sig);
        trimmed_duration = trimmed_samps / original_fs;
        trimmed_t = linspace(1, trimmed_duration, trimmed_samps);

        % Update plot
        figure(1)
        plot(trimmed_t, trimmed_sig)
        xlabel('Time (seconds)')
        ylabel('Amplitude (arb)')
        title('Trimmed Time Domain Signal', 'FontWeight', 'bold')
        set(gcf, 'Position', [100 100 700 450])

        % Trim again?
        proceed = questdlg('Proceed to analysis or re-trim audio?', 'Re-trim audio',...
            'Proceed', 'Re-trim', 'Proceed');
        
        % Do more trimming until happy to proceed
        while strcmpi(proceed, 'Re-trim')
            
            % Decide how to retrim
            how2trim = questdlg(['Return to full-length, orignal file to re-trim,', newline...
                'or continue trimming from previous window?'],...
                'Re-trim Audio', 'Return to original', 'Continue', 'Continue');
            
            % Set input vector as per "how2trim"
            switch how2trim
                case 'Return to Original'
                    % signal = signal; ie. do nothing.
                case 'Continue'
                    signal = trimmed_sig;
                    samps = length(signal);
                    duration = samps / original_fs;
                    t = linspace(0, duration, samps);
            end

            % Plot time domain signal
            close 1
            t_start_init = num2str(t(1));
            t_end_init = num2str(t(end));
            figure(1)
            plot(t, signal)
            xlabel('Time (seconds)')
            ylabel('Amplitude (arb)')
            title('Original Time Domain Signal', 'FontWeight', 'bold')
            set(gcf, 'Position', [100 100 700 450])

            % Set new Start and End times via UI Dialog
            prompt = {'Enter new start time (seconds):',...
                'Enter new end time (seconnds):'};
            dlgtitle = 'Enter new start & end times';
            dims = [1 50];
            definput = {t_start_init, t_end_init};
            trim_params = inputdlg(prompt,dlgtitle,dims,definput);

            % Handle Invalid Entries
            if str2double(trim_params{1}) < t(1) || str2double(trim_params{1}) > t(end)
                uiwait(msgbox('Error: Invalid Start Time'));
                prompt = {'Enter new start time (seconds):',...
                    'Enter new end time (seconnds):'};
                dlgtitle = 'Enter new start & end times';
                dims = [1 50];
                definput = {t_start_init, t_end_init};
                trim_params = inputdlg(prompt,dlgtitle,dims,definput);
            elseif str2double(trim_params{2}) < t(1) || str2double(trim_params{2}) > t(end)
                uiwait(msgbox('Error: Invalid End Time'));
                prompt = {'Enter new start time (seconds):',...
                    'Enter new end time (seconnds):'};
                dlgtitle = 'Enter new start & end times';
                dims = [1 50];
                definput = {t_start_init, t_end_init};
                trim_params = inputdlg(prompt,dlgtitle,dims,definput);
            elseif str2double(trim_params{1}) > str2double(trim_params{2})
                uiwait(msgbox('Error: Start Time Must Be Smaller Than End Time'));
                prompt = {'Enter new start time (seconds):',...
                    'Enter new end time (seconds):'};
                dlgtitle = 'Enter new start & end times';
                dims = [1 50];
                definput = {t_start_init, t_end_init};
                trim_params = inputdlg(prompt,dlgtitle,dims,definput);
            end

            % Extract Params
            t_start = str2double(trim_params(1));
            t_end = str2double(trim_params(2));

            % Trim signal
            [~,start_idx] = min(abs(t - t_start));
            [~,end_idx] = min(abs(t - t_end));
            trimmed_sig = signal(start_idx:end_idx);
            trimmed_samps = length(trimmed_sig);
            trimmed_duration = trimmed_samps / original_fs;
            trimmed_t = linspace(1, trimmed_duration, trimmed_samps);

            % Update plot
            figure(1)
            plot(trimmed_t, trimmed_sig)
            xlabel('Time (seconds)')
            ylabel('Amplitude (arb)')
            title('Trimmed Time Domain Signal', 'FontWeight', 'bold')
            set(gcf, 'Position', [100 100 700 450])

            % Trim again?
            proceed = questdlg('Proceed to analysis or re-trim audio?', 'Re-trim audio',...
                'Proceed', 'Re-trim', 'Proceed');

            close 1
        end
        signal = trimmed_sig;
    case 'Proceed'
end

clearvars t duration start_idx end_idx t_start t_end samps trimmed_samps trimmed_duration trimmed_sig trimmed_t

%% User Interaction: Resample audio

resample = questdlg(['Original sample rate is ', num2str(original_fs), 'Hz. ',...
    'Do you want to resample to a lower Fs?', newline, ...
    'NOTE: Sample rate determines upper limit for analysis frequency range', newline,...
    'Sample rates higher than 5000Hz may take a long time to compute.'],...
    'Downsample Audio?', 'Yes', 'No', 'No');

switch resample
    case 'Yes'
        while strcmpi(resample, 'Yes')

            % Set Analysis Sampling Frequency (UI Dialog)
            prompt = ['Enter a new, lower sample rate:', newline,...
                newline, 'Upper frequency limit = sample rate / 2'];
            dlgtitle = 'Sample Rate Conversion';
            definput = {num2str(original_fs/2)};
            dims = [1 50];
            fs = str2double(inputdlg(prompt,dlgtitle,dims,definput));

            % Handle invalid input
            if fs > original_fs
                uiwait(msgbox('Error: New fs must be lower than original fs.'));
                prompt = ['Enter a new, lower sample rate:', newline,...
                    newline, 'Upper frequency limit = sample rate / 2'];
                dlgtitle = 'Sample Rate Conversion';
                definput = {num2str(original_fs/2)};
                dims = [1 50];
                fs = str2double(inputdlg(prompt,dlgtitle,dims,definput));
            end

            % Resampling progress bar
            wbar = waitbar(0.25,'Please wait, resampling audio...');
            signal_downsamp = easySRC(signal, original_fs, fs, fs/2);
            waitbar(0.75, wbar, 'Please wait, resampling audio...')
            pause(1)
            close(wbar)

            % Plot a quick spectrogram to check if sample rate is appropriate
            W = 0.2;
            O = 0.175;
            [s1, f1, t1] = spectrogram(signal, ceil(W*original_fs), ceil(O*original_fs),...
                1024, original_fs, "yaxis");
            [s2, f2, t2] = spectrogram(signal_downsamp,  ceil(W*fs), ceil(O*fs),...
                1024, fs, "yaxis");
            s1 = 20*log10(abs(s1) .^ 2);
            s2 = 20*log10(abs(s2) .^ 2);
            s1 = s1 ./ max(abs(s1));
            s2 = s2 ./ max(abs(s2));
            figure(1)
            tiledlayout(2,1)
            nexttile
            surf(f1, t1, s1', EdgeColor = 'none', FaceColor='texturemap')
            xlabel('Frequency (Hz)');
            ylabel('Time (Seconds)');
            zlabel('Power (arb, normalized)');
            title(['Original Fs= ', num2str(original_fs), ' Hz'])
            set(gca, XDir="reverse", View=[90 90])
            nexttile
            surf(f2, t2, s2', EdgeColor = 'none', FaceColor='texturemap')
            xlabel('Frequency (Hz)');
            ylabel('Time (Seconds)');
            zlabel('Power (arb, normalized)');
            title(['Downsampled Fs= ', num2str(fs), ' Hz'])
            set(gca, XDir="reverse", View=[90 90])
            sgtitle(['Preliminary STFT Spectrogram', newline, ...
                'Signal of interest should be within bounds of plot.', newline...
                'Downsample further if upper frequencies contain no signals of interest.', newline], 'FontWeight', 'bold')
            set(gcf, 'Position', [100 100 700 650])

            % Resample again?
            resample = questdlg('Do you need to downsample again?',...
                'Resample again?', 'Yes', 'No', 'No');
            close 1
        end
    case 'No'
        fs = original_fs;
end

if exist('signal_downsamp', 'var')
    signal = signal_downsamp;
else
end

clearvars si s2 f1 f2 t1 t2 tf W O prompt dlgtitle definput dims signal_downsamp

%% Start Anaysis Loop
run_loop = 'Yes';
while strcmp(run_loop, 'Yes') == 1
    %% User Interaction: Set Analysis Algorithm Parameters

    % NOTE Maximum frequency of interest is automatically set according
    % to the sample rate, ie. fmax = fs/2
    % To change the fmax, the script will provde an opportunity (Via a dialog)
    % to downsample the audio to a lower sample rate.

    % Global Parameters
    prompt = {'Enter lowest frequency of interest (Hz):',...
        'Enter target frequency resolution (Hz):'};
    dlgtitle = 'Enter Global Parameters';
    dims = [1 50];
    definput = {'10', '0.1'};
    global_params = inputdlg(prompt,dlgtitle,dims,definput);
    fmin = str2double(global_params(1));    % Lowest frquency of interest (Hz)
    f_res = str2double(global_params(2));   % Frequency resolution (Hz)

    % STFT Parameters
    prompt = {['Enter number of points to use in STFT Fourier transform:', newline,...
        'NOTE: Values other than the default will change STFT ',...
        'frequency resolution from the global setting, and high values ',...
        'will result in long compute times.'],...
        'Enter Short-STFT Window Size (pts):',...
        'Enter Short-STFT overlap amount (%):',...
        'Enter Long-STFT window size (pts):',...
        'Enter Long-STFT overlap amount (%):'};
    dlgtitle = 'Enter Short-Time Fourier Transform Parameters';
    dims = [1 75];
    definput = {num2str(fs/f_res), '250', '75', '50', '75'};
    STFT_params = inputdlg(prompt,dlgtitle,dims,definput);
    n_fft = str2double(STFT_params(1));         % STFT FFT length (samples)
    win_long = str2double(STFT_params(2));      % Window length for longSTFT (samples)
    overlap_long = str2double(STFT_params(3));  % Window overlap for longSTFT (%)
    win_short = str2double(STFT_params(4));     % Window length for shortSTFT (samples)
    overlap_short = str2double(STFT_params(5)); % Window Overlap for shortSTFT (%)

    % CWT Parameters
    prompt = {['Enter time bandwidth product for Morse wavelet:', newline,...
        'Must be ≥3 and ≤120'],...
        ['Enter number of voices per octave:', newline,'Must be ≥10 and ≤48']};
    dlgtitle = 'Enter Continuous Wavelet Transform Parameters';
    dims = [1 75];
    definput = {'60', '48'};
    CWT_params = inputdlg(prompt,dlgtitle,dims,definput);
    time_bandwidth = str2double(CWT_params(1)); % Time bandwidth product of Morse wavelet.
    vpo = str2double(CWT_params(2));            % Voices per Octave. Must be in range 10 : 48

    % Superlet Parameters
    prompt = {'Enter Initial number of cycles in Superlet:',...
        'Enter lower superresolution order:',...
        'Enter upper superresolution order:',...
        ['Select superresolution mode.', newline,...
        'Enter 0 for additive, or 1 for multiplicative:']};
    dlgtitle = 'Enter Superlet Transform Parameters';
    dims = [1 75];
    definput = {'3', '10', '40', '1'};
    SWT_params = inputdlg(prompt,dlgtitle,dims,definput);
    c1 = str2double(SWT_params(1));                     % Initial number of cycles in superlet.
    order = str2double([SWT_params(2), SWT_params(2)]); % Interval of superresolution orders
    mult =  str2double([SWT_params(2), SWT_params(2)]); % Multiplicative (1) or additive (0) superresolution

    % save some ram:
    clearvars dims dlgtitle prompt global_params STFT_params CWT_params SWT_params definput

    %% User Interaction: Set Units and Plotting Parameters

    % Dialog box to ask whether to plot frequency as lin or log.
    freqplotscaling = questdlg('Plot Frequency Axis on Linear or Logarithmic Scale?',...
        'Frequency Axis Scaling', 'lin', 'log', 'log');

    % Select between the following signal strength units:
    list = {'magnitude', 'magdb', 'power', 'powdb'};
    % 'magnitude'   - Units remain unchanged, function only applies normalization.
    % 'magdb'       - Magnitude, expressed on a log scale, ie Decibels.
    % 'power'       - Power expressed on a linear scale, ie watts.
    % 'powdb'       - Power expressed on a logarithmic scale, ie dBW.

    % Dialog box to ask what units to plot signal strength in:
    [indx,tf] = listdlg('PromptString',{'Select Signal Strength Units:'},...
        'SelectionMode','single','ListString',list);

    % Make sure something is selected. If not, warn & display the dialog again:
    while tf~=1
        uiwait(msgbox("Error: You must select units to plot!","Error","modal"));
        [indx,tf] = listdlg('PromptString',{'Select Signal Strength Units:'},...
            'SelectionMode','single','ListString',list);
    end

    % Set the units
    units = list{indx};

    % Save some RAM
    clearvars indx prompt definput dims

    % Notify before save dialog
    uiwait(msgbox('Please select a directory to save the results...'));

    % Select directory to save figures to
    savepath = uigetdir(home, 'Select Save Directory' );

    %% Vectors and Counts

    % Highest frequency of interest (Hz)
    fmax = fs/2;

    % Frequency & samp counts
    n_samps = length(signal);
    n_freqs = (fmax-fmin) / f_res;

    % Time vector
    t_vec = linspace(0, n_samps/fs, n_samps);

    % Frequency vector
    f_vec = linspace(fmin, fmax, n_freqs);

    %% Prepare the Signal:

    % Normalize amplitude of signal so that abs(max(signal)) = 1.
    signal = signal ./ max(abs(signal));

    %% Compute Transforms

    % Progress Bar
    wbar = waitbar(0.2, 'Please wait, computing short-STFT...');
    pause(1)

    % Compute Short Window STFT
    [stft_short, stftshort_freq, stftshort_time] = spectrogram(signal, ...
        win_short, ceil(win_short*(overlap_short/100)), n_fft, fs, "yaxis");

    % Progress Bar
    waitbar(0.3, wbar, 'Please wait, computing long-STFT...');
    pause(1)

    % Compute Long Window STFT
    [stft_long, stftlong_freq, stftlong_time] = spectrogram(signal, ...
        win_long, ceil(win_long*(overlap_long/100)), n_fft, fs, "yaxis");

    % Progress Bar
    waitbar(0.40, wbar, 'Please wait, computing CWT...');
    pause(1)

    % Compute CWT
    [cwlet, f_cwt] = cwt(signal, fs, VoicesPerOctave=vpo, timeBandWidth=time_bandwidth, FrequencyLimits=[fmin fmax]);

    % Progress Bar
    waitbar(0.60, wbar, 'Please wait, computing SLT...');

    % Compute superlets
    swlet = nfaslt(signal, fs, [fmin, fmax], n_freqs, c1, order, mult);

    %% Unit Conversions

    % Convert algorithm outputs real magnitude
    stft_short = abs(stft_short);  % spectrogram returns complex data. Take absolute value to get magnitude.
    stft_long = abs(stft_long);    % spectrogram returns complex data. Take absolute value to get magnitude.
    cwlet = abs(cwlet);            % cwt returns complex data. Take absolute value to get magnitude.
    swlet = sqrt(swlet);           % nfaslt returns squre of magnitude (power). Take sqrt for magnitude.

    % Perform unit conversions and normalizations on TFRs
    stft_short = TFRunitconvertNorm(stft_short, units);
    stft_long = TFRunitconvertNorm(stft_long, units);
    cwlet = TFRunitconvertNorm(cwlet, units);
    swlet = TFRunitconvertNorm(swlet, units);

    %% Plotting

    % Progress Bar
    waitbar(0.9, wbar, 'Please wait, generating plots...');
    pause(2)

    % Plotting

    paramstoprint = ['fs=', num2str(fs), '_',...
        'fres=', num2str(f_res), '_', 'fmin=', num2str(fmin), '_',...
        '_', units];

    switch units
        case 'magnitude'
            magnitude_unit = 'Magnitude (arbitrary)';
        case 'magdb'
            magnitude_unit = 'Magnitude (dB)';
        case 'power'
            magnitude_unit = 'Power (W)';
        case 'powdb'
            magnitude_unit = 'Power (dBW)';
    end

    timelim = [0, t_vec(end)];
    freqlim = [fmin, fmax];

    switch freqplotscaling
        case 'log'
            mid_tick =  round((fmax-(fmax/2)), -2);
            low_tick = round((fmax-fmin)*0.2, -2);
            freqticks = [fmin, low_tick, mid_tick, fmax];
        case 'lin'
            if (fmax-fmin) > 10 && (fmax-fmin) < 125
                freqticks = fmin:10:fmax;
            elseif (fmax-fmin) >125 && (fmax-fmin) < 500
                freqticks = fmin:50:fmax;
            elseif (fmax-fmin) > 500 && (fmax-fmin) < 1500
                freqticks = fmin:100:fmax;
            end
    end

    % Dynamic STFT Names
    stftshort_name = ['STFT Spectrogram, ', num2str(win_short), 'pt. Window'];
    stftlong_name = ['STFT Spectrogram, ', num2str(win_long), 'pt. Window'];

    % Time domain
    figure(1)
    plot(t_vec, signal)
    ylabel('Amplitude (arbitrary)', FontWeight='normal');
    title('Time Domain Signal', FontSize=16, FontWeight='bold'); 
    xlabel('Time (Seconds)');
    ylim([-1.2 1.2])
    xlim(timelim)

    set(gcf, 'Position', [20 500 1000 500])
    % Save figures
    savename = ['Time_Domain_', file(1:end-4), '_', paramstoprint, '.svg'];
    saveas(gcf, fullfile(savepath, savename), 'svg')

    % Plot STFT with Short Window
    figure(2)
    surf(stftshort_freq, stftshort_time, stft_short', EdgeColor = 'none', FaceColor='texturemap')
    title([stftshort_name], FontSize=16, FontWeight='bold')
    axis on
    grid on
    xlabel('Frequency (Hz)');
    ylabel('Time (Seconds)');
    xlim(freqlim)
    ylim(timelim)
    xticks(freqticks)
    set(gca, XDir="reverse", View=[90 90], xscale = freqplotscaling)
    ax = gca;
    ax.Layer = 'top';
    ax.GridColor = [1 1 1];
    ax.GridAlpha = 0.15;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    ax.MinorGridLineStyle = ':';
    ax.MinorGridColor = [1 1 1];
    ax.MinorGridAlpha = 0.15;
    c = colorbar;
    c.Label.String = magnitude_unit;

    set(gcf, 'Position', [40 400 1000 500])
    % Save figures
    savename = ['ShortWin_STFT_', file(1:end-4), '_', paramstoprint, '.svg'];
    saveas(gcf, fullfile(savepath, savename), 'svg')

    % Plot STFT with Long Window
    figure(3)
    surf(stftlong_freq, stftlong_time, stft_long', EdgeColor = 'none', FaceColor='texturemap')
    title([stftlong_name], FontSize=16, FontWeight='bold')
    axis on
    grid on
    xlabel('Frequency (Hz)');
    ylabel('Time (Seconds)');
    xlim(freqlim)
    ylim(timelim)
    xticks(freqticks)
    set(gca, XDir="reverse", View=[90 90], xscale = freqplotscaling)
    ax = gca;
    ax.Layer = 'top';
    ax.GridColor = [1 1 1];
    ax.GridAlpha = 0.15;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    ax.MinorGridLineStyle = ':';
    ax.MinorGridColor = [1 1 1];
    ax.MinorGridAlpha = 0.15;
    c = colorbar;
    c.Label.String = magnitude_unit;

    set(gcf, 'Position', [60 300 1000 500])
    % Save figures
    savename = ['LongWin_STFT_', file(1:end-4), '_', paramstoprint, '.svg'];
    saveas(gcf, fullfile(savepath, savename), 'svg')

    % Plot CWT
    figure(4)
    surf(f_cwt, t_vec, cwlet', EdgeColor="none", FaceColor="texturemap")
    title('CWT Scalogram', FontSize=16, FontWeight='bold') 
    axis on
    grid on
    xlabel('Frequency (Hz)');
    ylabel('Time (Seconds)');
    xlim(freqlim)
    ylim(timelim)
    xticks(freqticks)
    set(gca, XDir="reverse", View=[90 90], xscale = freqplotscaling)
    ax = gca;
    ax.Layer = 'top';
    ax.GridColor = [1 1 1];
    ax.GridAlpha = 0.15;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    ax.MinorGridLineStyle = ':';
    ax.MinorGridColor = [1 1 1];
    ax.MinorGridAlpha = 0.15;
    c = colorbar;
    c.Label.String = magnitude_unit;

    set(gcf, 'Position', [80 200 1000 500])
    % Save figures
    savename = ['CWT_', file(1:end-4), '_', paramstoprint, '.svg'];
    saveas(gcf, fullfile(savepath, savename), 'svg')

    % Plot Superlets
    figure(5)
    surf(f_vec, t_vec, swlet', EdgeColor="none", FaceColor="texturemap")
    title('Superlet Scalogram', FontSize=16, FontWeight='bold') 
    axis on
    grid on
    xlabel('Frequency (Hz)');
    ylabel('Time (Seconds)');
    xlim(freqlim)
    ylim(timelim)
    xticks(freqticks)
    set(gca, XDir="reverse", View=[90 90], xscale = freqplotscaling)
    ax = gca;
    ax.Layer = 'top';
    ax.GridColor = [1 1 1];
    ax.GridAlpha = 0.15;
    ax.XMinorGrid = 'on';
    ax.YMinorGrid = 'on';
    ax.MinorGridLineStyle = ':';
    ax.MinorGridColor = [1 1 1];
    ax.MinorGridAlpha = 0.15;
    c = colorbar;
    c.Label.String = magnitude_unit;

    set(gcf, 'Position', [100 100 1000 500])
    % Save figures
    savename = ['SLT_', file(1:end-4), '_', paramstoprint, '.svg'];
    saveas(gcf, fullfile(savepath, savename), 'svg')

    % Close progress bar
    close(wbar)

    %% User Interaction: Repeat Analysis?
    run_loop = questdlg('Do you want to re-run the TF analysis on the same audio?', 'Re-Run Analysis?', 'Yes', 'No', 'No');

end
