% 教學範例：生成樣本波型並計算其STFT
% 1. 取樣頻率 Fs = 250
% 2. 產生一個樣本波型
%    - 0到2秒: 5Hz 振幅3 + 8Hz 振幅5 + 17Hz 振幅2 的複合波型
%    - 3到5秒: 8Hz 振幅3 + 17Hz 振幅7 的複合波型
% 3. 繪製STFT(短時距傅立葉轉換)圖，不使用dB，使用振幅單位

% clear all;
% close all;

x = data(2,:);

% 參數設置
Fs = 250; % 取樣頻率 (Hz)
T = 1/Fs; % 取樣周期 (秒)
N = length(x);% 數據點數
t_total = (N-1) * T; % 總時間 (秒)
t = (0:T:t_total)/60; % 時間向量

% 繪製原始波型
figure;
plot(t, x);
title('原始樣本波型');
xlabel('時間 (分鐘)');
ylabel('振幅');
grid on;

% 計算並繪製 STFT
win = hamming(250);     % 使用 Hamming 窗口
noverlap = 125;         % 重疊部分
nfft = 256;             % FFT 點數

% [sx,fx,tx] = spectrogram(x, win, noverlap, nfft,Fs);



[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, Fs,"psd");

% 繪製 STFT 圖，不使用 dB
figure;
surf(t_stft, f, abs(ps), 'EdgeColor', 'none');
axis xy; axis tight; view(0, 90);
title('短時傅里葉變換 (STFT)');
xlabel('時間 (秒)');
ylabel('頻率 (Hz)');
colorbar;
clim([0 20]);
colormap Turbo;
ylabel(colorbar, '振幅');
