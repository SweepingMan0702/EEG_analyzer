files = cell(2);
% 選擇檔案
disp('選擇工作階段檔案(.mat)');
[file1, path1] = uigetfile({'*.mat;*.txt;*.csv', 'Supported Files (*.mat, *.txt, *.csv)'; ...
                            '*.mat', 'MAT-files (*.mat)'; ...
                            '*.txt', 'Text Files (*.txt)'; ...
                            '*.csv', 'CSV Files (*.csv)'}, ...
                            'Select the first file');
if isequal(file1, 0)
    disp('User canceled the first file selection.');
else
    fullFileName1 = fullfile(path1, file1);
    files{1} = fullFileName1;
end

disp('選擇緩解後檔案(.mat)');
[file2, path2] = uigetfile({'*.mat;*.txt;*.csv', 'Supported Files (*.mat, *.txt, *.csv)'; ...
                            '*.mat', 'MAT-files (*.mat)'; ...
                            '*.txt', 'Text Files (*.txt)'; ...
                            '*.csv', 'CSV Files (*.csv)'}, ...
                            'Select the second file');
if isequal(file2, 0)
    disp('User canceled the second file selection.');
else
    fullFileName2 = fullfile(path2, file2);
    files{2} = fullFileName2;
end

%選擇器
pause(0.3);
options = {'2channel','4channel'};
choice = menu('請選擇一個選項：', options);
switch choice
    case 1
        ch = 1;
    case 2
        ch = 2;
end

signal = {'Cz' , 'Fz'};

% for  turns = 1: length(signal)
for  turns = 1: 1
%檔案讀取
data_vars = {'x_test', 'x_recovered'};
for i = 1:length(files)
    load(files{i}, 'data');
    assignin('base', data_vars{i}, data(ch+turns-1,:));
end

path = [path1 signal{turns} '_result'];
mkdir(path);

% 參數設置
Fs = 250;

% 計算並繪製 STFT
win = hamming(250);
noverlap = 125;
nfft = 256;
stft_data = {x_test, x_recovered};
stft_results = cell(size(stft_data));

for i = 1:length(stft_data)
    [~, f, t_stft, ps] = spectrogram(stft_data{i}, win, noverlap, nfft, Fs, "ps");
    stft_results{i} = {f, t_stft, abs(ps)};
end


% 分布圖
base_samples = 3 * 60; %共180秒
fatigue_samples = 5 * 60;
t_index_base = stft_results{1}{2} <= base_samples; %對應到第360個點，形成一個mask
t_index_fatigue = stft_results{1}{2} >= (max(stft_results{1}{2}) - fatigue_samples);

ps_base = stft_results{1}{3}(:, t_index_base);
ps_fatigue = stft_results{1}{3}(:, t_index_fatigue);
ps_recovered = stft_results{2}{3};

freq_bands = {[8 12], [12 35], [4 7]};
band_names = {'Alpha (8-12 Hz)', 'Beta (12-35 Hz)', 'Theta (4-7 Hz)'};

total_energy = cell(3,1);

%stft_results{1}是頻率的list
for i = 1:length(freq_bands)
    max = 0;
    % 计算每个频段的能量数据
    freq_index = (stft_results{1}{1} >= freq_bands{i}(1)) & (stft_results{1}{1} <= freq_bands{i}(2));
    
    % 第一阶段：前三分钟
    ps_band_base = ps_base(freq_index, :);
    energy_base = sum(ps_band_base, 1);
    %ex(第一輪): 將base的alpha放進total_energy{1}的第一列
    total_energy{1}{1,i} = energy_base';
    
    % 第二阶段：最后五分钟
    ps_band_fatigue = ps_fatigue(freq_index, :);
    energy_fatigue = sum(ps_band_fatigue, 1);
    total_energy{i}{2,i} = energy_fatigue';

    % 第三阶段：recovered整段
    ps_band_recovered = ps_recovered(freq_index, :);
    energy_recovered = sum(ps_band_recovered, 1);
    total_energy{i}{3,i} = energy_recovered';
end

% 假設您的數據存儲在名為 test 的變量中
% test 是一個 1000 x 3 的矩陣 [alpha_ps beta_ps theta_ps]

% 步驟 1: 計算每列的四分位數
test = [total_energy{1}{1} total_energy{1}{2} total_energy{1}{3}];
Q1 = quantile(test, 0.25);
Q3 = quantile(test, 0.75);
IQR = Q3 - Q1;

% 步驟 2: 定義離群值的範圍
lower_bound = Q1 - 1.5 * IQR;
upper_bound = Q3 + 1.5 * IQR;

% 步驟 3: 找出非離群值的行
valid_rows = all(test >= lower_bound & test <= upper_bound, 2);

% 步驟 4: 只保留非離群值的行
test_cleaned = test(valid_rows, :);

% 顯示結果
fprintf('原始數據行數: %d\n', size(test, 1));
fprintf('清理後數據行數: %d\n', size(test_cleaned, 1));
fprintf('移除的行數: %d\n', size(test, 1) - size(test_cleaned, 1));




% clearvars -except data_vars files signal turns ch path1;

close all;
end
disp('已將各圖檔儲存至資料夾內');


