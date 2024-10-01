%使用說明 *移除體動 (前後名平均取代標記點)
%資料需求: 選擇一資料夾內包含{base,fatigue,recovered}資料夾且內部需有.mat檔
%執行後原路徑生成"體動移除"資料夾，包含Cz、Fz等的ps資料(.mat共六個檔案)
%
save_switch = 1;

% 超過點能量大小 、 超過點個數
over_value = 0.2;
over_counts = 3;


fpath = uigetdir(pwd, 'Select a folder');
list = {'base','fatigue','recovered'};
channel = {'Cz','Fz'};

if save_switch == 1
    mkdir([fpath '\體動移除']);
    mkdir([fpath '\體動移除\圖片']);
end


for k = 1:length(list)
    temp_path = [fpath '\' list{k}];
%     matFiles = dir(fullfile(temp_path, '*.mat'));

    % for j = 1:length(matFiles)
    for j = 1:length(3)
        fileName = [temp_path, '.mat'];
        loaded_data = load(fileName);
        disp(['load : ' fileName]);
        % 查看加载的数据结构
        vars = fieldnames(loaded_data);
        % 假设只加载了一个变量，可以这样访问
        data = loaded_data.(vars{1});
        % 在這裡處理加載的數據
        
        for ch = 1:length(channel)
            figure;
            x = data(ch,:);
            fs = 250;
            win = hamming(250);
            noverlap = 125;
            nfft = 256;
            [~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");
            [r, c] = size(ps);
            finish = 0;
            count = 0;
            subplot(2,1,1);
            init_ps_len = length(ps);
            t_stft = t_stft(1,1:length(ps));
            surf(t_stft/60,f, ps, 'EdgeColor', 'none');
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

            % while finish == 0 && count < 1000
            %     count = count + 1;
            %     finish = 1;
            %     for cs = 1:c
            %         % 檢查30~50行中是否有3個值超過0.2
            %         if sum(ps(30:50, cs) > over_value) >= over_counts
            %             finish = 0;
            %             break;
            %         end
            %     end
            %     if finish == 0
            %         ps = process_array(ps, over_value, over_counts);
            %     end
            % end
            ps = process_array(ps, over_value, over_counts);
            
            del_ps_len = round((init_ps_len - length(ps)) / init_ps_len * 100 , 1);
            subplot(2,1,2);
            t_stft = t_stft(1,1:length(ps));
            surf(t_stft/60,f, ps, 'EdgeColor', 'none');
            axis xy; axis tight; view(0, 90);
            title(['短時傅里葉變換 (STFT) - ' list{k} '-' channel{ch} ]);
            subtitle(['remove ' num2str(del_ps_len) '%'])
            xlabel('時間 (分)');
            ylabel('頻率 (Hz)');
            colorbar;
            clim([0, 20]);
            ylim([0, 60]);
            colormap Turbo;
            ylabel(colorbar, '振幅');
            set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);

    
            result_file_name = sprintf([list{k} '_' channel{ch}]);
            full_path = fullfile([fpath '\體動移除'] , [result_file_name '.mat']);
            pic_path = fullfile([fpath '\體動移除\圖片'] , [result_file_name '.png']);
            
            % 保存這個時間段的數據
            if save_switch == 1
                save([full_path], 'ps','t_stft','f');
                
                saveas(gcf, pic_path);
                close all;
            end

        end
        clearvars -except fpath list channel temp_path matFiles over_value over_counts save_switch;
    end
end









function result = process_array(input_array, over_value, over_counts)
    % 獲取數組的大小
    [rows, cols] = size(input_array);

    % 創建結果數組，初始為輸入數組的副本
    result = input_array;

    % 處理需要修改的列
    for col = 1:cols
        % 檢查30~50行中是否有3個值超過0.2
        if sum(input_array(30:50, col) > over_value) >= over_counts
            for row = 1:rows
                % 本來取平均，修改成直接取代 
                % % 計算左右兩個數的平均值
                % if col == 1
                %     avg = (input_array(row, 2) + input_array(row, end)) / 2;
                % elseif col == cols
                %     avg = (input_array(row, 1) + input_array(row, end-1)) / 2;
                % else
                %     avg = (input_array(row, col-1) + input_array(row, col+1)) / 2;
                % end
                % 替換值
                result(row, col) = 0;
            end
        end
    end
    result(:, all(result == 0)) = [];  % 移除全为 0 的列
end




