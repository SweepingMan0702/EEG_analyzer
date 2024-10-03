%請自行讀取檔案
%用以查看數據STFT狀況 以便切割訊號

cz = data(1,:);
fz = data(2,:);
figure;
subplot(2,1,1);
spectrogram(cz, 1250, 1125, 1024, 250, 'yaxis');
ylim([0 60]);
clim([-10,20]);
colormap('turbo');
grid on;
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
title('CZ Spectrogram');

subplot(2,1,2);
spectrogram(fz, 1250, 1125, 1024, 250, 'yaxis');
title('FZ Spectrogram');  
ylim([0 60]);
clim([-10,20]);
grid on;
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
colormap('turbo');
clear all;