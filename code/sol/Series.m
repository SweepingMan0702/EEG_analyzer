fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Fz','fatigue_Fz','recovered_Fz'};
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
            total_ps = horzcat(total_ps, loaded_data.ps);
        end
        
    end
    
    % 在這裡保存或處理 total_ps
    save(fullfile(fpath, [data_list{data_files} '_combined.mat']), 'total_ps', 't_stft', 'f');
    clear total_ps;
end