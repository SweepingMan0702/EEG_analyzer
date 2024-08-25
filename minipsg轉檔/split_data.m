[fname, fpath] = uigetfile('*.mat;*.mat','Select the Ble-file');
load([fpath fname]);

if size(data, 1) == 2
    eeg_data_Cz = data(1,:);
    eeg_data_Fz = data(2,:);
elseif size(data, 1) == 4
    eeg_data_Cz = data(2,:);
    eeg_data_Fz = data(3,:);
end

% 假設您的EEG數據存儲在變量'eeg_data_Cz'和'eeg_data_Fz'中
% 每個變量的格式應該是: 1行多列，列代表時間點

% 設定參數
sampling_rate = 250;  % 每秒250個樣本

% 讓用戶輸入時間段
% num_segments = input('請輸入想要分析的時間段數量: ');
num_segments = 3;
time_segments = zeros(num_segments, 2);


time_segments(1, 1) = 0*60;
time_segments(1, 2) = 3*60;
time_segments(2, 1) = 4*60;
time_segments(2, 2) = 23*60;
time_segments(3, 1) = 27*60;
time_segments(3, 2) = 30*60;

% for i = 1:num_segments
%     fprintf('請輸入第 %d 個時間段的開始和結束時間（分）:\n', i);
%     time_segments(i, 1) = input('開始時間: ')*60;
%     time_segments(i, 2) = input('結束時間: ')*60;
% end

% 創建資料夾來存儲所有分割後的文件
% folder_name = 'split_data';
% if ~exist(folder_name, 'dir')
%     mkdir(folder_name);
% end
state = {'base','working','fatigue'};
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
    file_name = sprintf('segment_%d.mat', i);
    full_path = fullfile(fpath, state{i}, file_name);
    % full_path = fullfile(fpath, 'recovered', file_name);
    
    % 保存這個時間段的數據
    save(full_path, 'segment_data');
    
    fprintf('時間段 %d 的數據已保存到: %s\n', i, full_path);
end

% 保存時間段信息
% time_info_path = fullfile(pwd, folder_name, 'time_segments_info.mat');
% save(time_info_path, 'time_segments', 'sampling_rate');

fprintf('所有時間段數據已被分割並保存到 %s 資料夾中。\n', path);
% fprintf('時間段信息已保存到: %s\n', time_info_path);
clear all;
