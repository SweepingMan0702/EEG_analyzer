x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");

ps = process_array(ps);


figure;
surf(t_stft/60,f, ps, 'EdgeColor', 'none');
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
    
    % 創建一個邏輯數組，標記哪些列需要處理
    % 值超過1 佔該時間的25%
    cols_to_process = sum(input_array > 1) > 0.25 * rows;
    
    % 創建結果數組，初始為輸入數組的副本
    result = input_array;
    
    % 處理需要修改的列
    for col = find(cols_to_process)
        for row = 1:rows
            % 計算左右兩個數的平均值
            if col == 1
                avg = (input_array(row, 2) + input_array(row, end)) / 2;
            elseif col == cols
                avg = (input_array(row, 1) + input_array(row, end-1)) / 2;
            else
                avg = (input_array(row, col-1) + input_array(row, col+1)) / 2;
            end
            
            % 替換值
            result(row, col) = 0;
        end
    end
end