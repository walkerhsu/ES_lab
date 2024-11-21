% Parameters
fs = 100e3;          % Sampling frequency (100 kHz)
N = 320;             % Number of sample points
t = (0:N-1)/fs;      % Time vector (320 points)

% Signals
f1 = 1e3;            % Frequency of first signal (1 kHz)
f2 = 15e3;           % Frequency of second signal (15 kHz)
signal = sin(2*pi*f1*t) + sin(2*pi*f2*t);
disp(signal)
% Frequency domain analysis (original signal)
fft_signal = fft(signal);                % Compute FFT
frequencies = (0:N-1)*(fs/N);            % Frequency vector
amplitude_original = abs(fft_signal)/N;  % Normalize amplitude

% Design and apply FIR filter
h = fir1(28, 6/24);                      % FIR filter with cutoff at 6 kHz (normalized)
filtered_signal = filter(h, 1, signal);  % Apply the FIR filter

% Frequency domain analysis (filtered signal)
fft_filtered = fft(filtered_signal);    % FFT of filtered signal
amplitude_filtered = abs(fft_filtered)/N; % Normalize amplitude

% Plot time domain signals
figure;
subplot(2,1,1);
plot(t, signal, 'b', 'DisplayName', 'Original Signal');
hold on;
plot(t, filtered_signal, 'r', 'DisplayName', 'Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain Signal');
legend;
grid on;

% Plot frequency domain signals
subplot(2,1,2);
plot(frequencies(1:N/2), amplitude_original(1:N/2)*2, 'b', 'DisplayName', 'Original Signal');
hold on;
plot(frequencies(1:N/2), amplitude_filtered(1:N/2)*2, 'r', 'DisplayName', 'Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Frequency Domain Signal');
legend;
grid on;
xlim([0 20e3]); % Limit frequency range to 20 kHz
