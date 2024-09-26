%資料彙總 讀取資料夾內同檔名資料ps"連接"並儲存
%建置_combined.mat並儲存


fpath = uigetdir(pwd, 'Select a folder');
channel = {'Cz','Fz'};

for index = 1:length(channel)
data_list = {['base_' channel{index}],['fatigue_' channel{index}],['recovered_' channel{index}]};

for data_files = 1:length(data_list)
    list = dir(fullfile(fpath, '**', '體動移除', [data_list{data_files} '.mat'])); % 查找所有符合条件的文件
    total_ps = [];
    for j = 1:length(list)
        fileName = fullfile(list(j).folder, list(j).name); % 構建完整路徑
        loaded_data = load(fileName);
        if j == 1
            total_ps = loaded_data.ps;
            t_stft = loaded_data.t_stft;
            f = loaded_data.f;
        else
            total_ps = [ total_ps loaded_data.ps ];
        end
        % length(total_ps)
        clear loaded_data;
    end
    
    % [data_list{data_files} '_combined.mat']
    % 在這裡保存或處理 total_ps
    save(fullfile(fpath, [data_list{data_files} '_combined.mat']), 'total_ps', 'f');
    clear total_ps;
end
end