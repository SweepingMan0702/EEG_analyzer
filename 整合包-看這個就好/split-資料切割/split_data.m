%選擇'轉檔後'.m檔案 並輸入狀態及想擷取的時間 (共3分鐘)
%將檔案儲存於 "切割後"資料夾

[fname, fpath] = uigetfile('*.mat;*.mat','Select the Ble-file');
load([fpath fname]);

% 获取上一层文件夹的路径
main_folder = fileparts(fpath(1:end-1));

list = {'base', 'fatigue', 'recovered'};
[choice, ok] = listdlg('ListString', list, 'SelectionMode', 'single','Name', 'state');

state = list{choice};
% 載入EEG數據
eeg_data_Cz = data(1,:);
eeg_data_Fz = data(2,:);
% 假設您的EEG數據存儲在變量'eeg_data_Cz'和'eeg_data_Fz'中
% 每個變量的格式應該是: 1行多列，列代表時間點

% 設定參數
sampling_rate = 250;  % 每秒250個樣本

% 讓用戶輸入時間段
num_segments = 1;
time_segments = zeros(num_segments, 2);
for i = 1:num_segments
    fprintf('請輸入開始和結束時間（分）:\n');
    time_segments(i, 1) = input("開始時間:")*60;
    time_segments(i, 2) = input("結束時間:")*60;
end

% 創建資料夾來存儲所有分割後的文件
new_folder = [main_folder '\切割後'];
mkdir(new_folder);

% 分割數據並保存每個段
for i = 1:num_segments
    start_sample = round(time_segments(i, 1) * sampling_rate) + 1;
    end_sample = round(time_segments(i, 2) * sampling_rate);
    
    % 確保不超出數據範圍
    end_sample = min(end_sample, size(eeg_data_Cz, 2));
    
    % 創建包含 Cz 和 Fz 數據的 2x[樣本數] 矩陣
    segment_data = [eeg_data_Cz(:, start_sample:end_sample);
                    eeg_data_Fz(:, start_sample:end_sample)];
    
    % 創建文件名
    file_name = sprintf([state '.mat']);
    full_path = fullfile(new_folder, file_name);
    
    % 保存這個時間段的數據
    save(full_path, 'segment_data');
    
    fprintf('時間段 %d 的數據已保存到: %s\n', i, full_path);
end

% 保存時間段信息
% time_info_path = fullfile(pwd, folder_name, 'time_segments_info.mat');
% save(time_info_path, 'time_segments', 'sampling_rate');

% fprintf('所有時間段數據已被分割並保存到 %s 資料夾中。\n', folder_name);
% fprintf('時間段信息已保存到: %s\n', time_info_path);
clear all;
