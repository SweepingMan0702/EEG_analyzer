x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");

ps(1,2)