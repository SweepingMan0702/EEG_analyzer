fpath = uigetdir(pwd, 'Select a folder');
list = {'base','fatigue','recovered'};
% list = {'base','working'};
channel = {'Cz','Fz'};

for k = 1:length(list)
    temp_path = [fpath '\' list{k}];
    matFiles = dir(fullfile(temp_path, '*.mat'));

    for j = 1:length(matFiles)
        %先load base
       
        fileName = fullfile(temp_path, matFiles(j).name);
        disp(fileName);
        load(fileName);
        % 在這裡處理加載的數據
        for ch = 1:length(channel)
            x = data(ch,:);
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

            figure;
            surf(t_stft,f, ps, 'EdgeColor', 'none');
            axis xy; axis tight; view(0, 90);
            title(['短時傅里葉變換 (STFT) - ' list{k} '-' channel{ch} ]);
            xlabel('時間 (分)');
            ylabel('頻率 (Hz)');
            colorbar;
            clim([0, 20]);
            ylim([0, 60]);
            colormap Turbo;
            ylabel(colorbar, '振幅');
            set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);

    
            result_file_name = sprintf([list{k} '_' channel{ch} '.mat']);
            full_path = fullfile([fpath '\體動移除'] , result_file_name);
            % 保存這個時間段的數據
            save(full_path, "ps");
        end
        clearvars -except fpath list channel temp_path matFiles;
    end
end


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
                % 替換值
                result(row, col) = avg;
            end
        end
    end
end