x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");


[rows, cols] = size(ps);

for col = 1:cols
    % 檢查30~50行中是否有10個值超過2
    if sum(ps(30:50, col) > 0.2) >= 10
        % 如果條件滿足，將整列設為0
        ps(:, col) = 0;
    end
end

figure;
surf(t_stft,f, ps, 'EdgeColor', 'none');
axis xy; axis tight; view(0, 90);
colorbar;
clim([0, 20]);
ylim([0, 60]);
colormap Turbo;
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
