% [fname, fpath] = uigetfile('*.mat;*.mat','Select file');

x = data(1,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");

[r, c] = size(ps);

ps = process_array(ps);
finish = 0;
count = 0;

while finish == 0 && count < 100
    count = count + 1;
    finish = 1;
    for cs = 1:c
        % 檢查30~50行中是否有3個值超過0.2
        if sum(ps(30:50, cs) > 0.2) >= 3
            finish = 0;
            break;
        end
    end
    if finish == 0
        ps = process_array(ps);
    end

end

a = mean(ps(4:30,:), 1);
figure;
surf(t_stft,f, ps, 'EdgeColor', 'none');
axis xy; axis tight; view(0, 90);
title(['短時傅里葉變換 (STFT) - ']);
xlabel('時間 (分)');
ylabel('頻率 (Hz)');
colorbar;
clim([0, 20]);
ylim([0, 60]);
colormap Turbo;
ylabel(colorbar, '振幅');
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);




function result = process_array(input_array)
    % 獲取數組的大小
    [rows, cols] = size(input_array);

    % 創建結果數組，初始為輸入數組的副本
    result = input_array;

    % 處理需要修改的列
    for col = 1:cols
        % 檢查30~50行中是否有3個值超過0.2
        if sum(input_array(30:50, col) > 0.2) >= 3
            for row = 1:rows
                % 計算左右兩個數的平均值
                if col == 1
                    avg = (input_array(row, 2) + input_array(row, end)) / 2;
                elseif col == cols
                    avg = (input_array(row, 1) + input_array(row, end-1)) / 2;
                else
                    avg = (input_array(row, col-1) + input_array(row, col+1)) / 2;
                end
                result(row,col) = avg;
            end
        end
    end
end