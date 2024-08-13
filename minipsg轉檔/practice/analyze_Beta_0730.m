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

for  turns = 1: length(signal)

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
T = 1/Fs;
N_test = length(x_test);
N_recovered = length(x_recovered);
t_test = (0:T:(N_test-1)*T)/60;
t_recovered = (0:T:(N_recovered-1)*T)/60;

% 設計帶通濾波器
filter_params = {[8, 12], [12, 35], [4, 7]};
filters = cell(size(filter_params));
for i = 1:length(filter_params)
    filters{i} = designfilt('bandpassiir', 'FilterOrder', 4, ...
        'HalfPowerFrequency1', filter_params{i}(1), ...
        'HalfPowerFrequency2', filter_params{i}(2), ...
        'SampleRate', Fs);
end

% 濾波處理
y_test = cell(size(filters));
y_recovered = cell(size(filters));
for i = 1:length(filters)
    y_test{i} = filtfilt(filters{i}, x_test);
    y_recovered{i} = filtfilt(filters{i}, x_recovered);
end

% 繪製濾波後的波型
titles = {
    '8-12 Hz 帶通濾波後的波型(Alpha波)', 
    '12-35 Hz 帶通濾波後的波型(Beta波)', 
    '4-7 Hz 帶通濾波後的波型(Theta波)'
};
file_suffixes = {'Alpha', 'Beta', 'Theta'};
time_vectors = {t_test, t_recovered};
%各有三個
data_vectors = {y_test, y_recovered};
data_files = {'work', 'recovered'};

for i = 1:length(data_vectors)
    for j = 1:length(data_vectors{i})
        figure;
        plot(time_vectors{i}, abs(data_vectors{i}{j}));
        title([titles{j}, ' - ', data_files{i}]);
        % xlim([0, 32]);
        ylim([0, 90]);
        xlabel('時間 (分鐘)');
        ylabel('振幅');
        grid on;
        set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
        saveas(gcf, [path, '\filt_', file_suffixes{j}, '_', data_files{i}, '.png']);
        close all;
    end
end

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

for i = 1:length(stft_results)
    figure;
    surf(stft_results{i}{2}/60, stft_results{i}{1}, stft_results{i}{3}, 'EdgeColor', 'none');
    axis xy; axis tight; view(0, 90);
    title(['短時傅里葉變換 (STFT) - ', data_files{i}]);
    xlabel('時間 (分)');
    ylabel('頻率 (Hz)');
    colorbar;
    clim([0, 20]);
    ylim([0, 60]);
    colormap Turbo;
    ylabel(colorbar, '振幅');
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
    saveas(gcf, [path, '\STFT_', data_files{i}, '.png']);
    close all;
end

% 分布圖
three_min_samples = 3 * 60; %共180秒
seven_min_samples = 7 * 60;
t_index_first3 = stft_results{1}{2} <= three_min_samples; %對應到第360個點，形成一個mask
disp(signal{turns});
t_index_last7 = stft_results{1}{2} >= (max(stft_results{1}{2}) - seven_min_samples);
ps_first3 = stft_results{1}{3}(:, t_index_first3);
ps_last7 = stft_results{1}{3}(:, t_index_last7);
ps_recovered = stft_results{2}{3};

freq_bands = {[8 12], [12 35], [4 7]};
band_names = {'Alpha (8-12 Hz)', 'Beta (12-35 Hz)', 'Theta (4-7 Hz)'};

% range = {[0 35] [0 40] [0 210]};

%stft_results{1}是頻率的list
for i = 1:length(freq_bands)
    max = 0;
    % 计算每个频段的能量数据
    freq_index = (stft_results{1}{1} >= freq_bands{i}(1)) & (stft_results{1}{1} <= freq_bands{i}(2));
    
    % 第一阶段：前三分钟
    ps_band_first3 = ps_first3(freq_index, :);
    energy_first3 = sum(ps_band_first3, 1);
    
    % 第二阶段：最后七分钟
    ps_band_last7 = ps_last7(freq_index, :);
    energy_last7 = sum(ps_band_last7, 1);

    % 第三阶段：recovered整段
    ps_band_recovered = ps_recovered(freq_index, :);
    energy_recovered = sum(ps_band_recovered, 1);

    [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_first3);
    if max < maxNonOutlier
        max = maxNonOutlier;
    end
    [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_last7);
    if max < maxNonOutlier
        max = maxNonOutlier;
    end
    [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_recovered);
    if max < maxNonOutlier
        max = maxNonOutlier;
    end


    % 创建新的图形窗口
    figure;
    
    % 绘制前三分钟能量分布的箱形图
    subplot(1, 3, 1);
    boxchart(energy_first3);
    % [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_first3);
    % ylim([minNonOutlier-5 maxNonOutlier+5]);
    ylim([0 max]);
    xlabel('能量大小'); ylabel('分布');
    title([band_names{i}, ' - 初始狀態']);
    grid on;
    
    % 绘制最后七分钟能量分布的箱形图
    subplot(1, 3, 2);
    boxchart(energy_last7);
    % [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_last7);
    % ylim([minNonOutlier-5 maxNonOutlier+5]);
    ylim([0 max]);
    xlabel('能量大小'); ylabel('分布');
    title([band_names{i}, ' - 疲勞狀態']);
    grid on;
    
    % 绘制recovered整段能量分布的箱形图
    subplot(1, 3, 3);
    boxchart(energy_recovered);
    % [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(energy_recovered);
    % ylim([minNonOutlier-5 maxNonOutlier+5]);
    ylim([0 max]);
    xlabel('能量大小'); ylabel('分布');
    title([band_names{i}, ' - 緩解恢復']);
    grid on;

    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
    saveas(gcf, [path '\boxchart_' band_names{i} '.png']);
end
clearvars -except data_vars files signal turns ch path1;
close all;
end
disp('已將各圖檔儲存至資料夾內');



%箱型圖範圍函式
function [minNonOutlier, maxNonOutlier] = calculateNonOutlierRange(data)
    % 计算箱线图统计数据
    Q1 = quantile(data, 0.25); % 第 25 百分位数 (Q1)
    Q3 = quantile(data, 0.75); % 第 75 百分位数 (Q3)
    IQR = Q3 - Q1; % 四分位距
    % 计算非离群值的范围
    lowerWhisker = Q1 - 1.5 * IQR; % 下胡须的最小值
    upperWhisker = Q3 + 1.5 * IQR; % 上胡须的最大值
    % 获取非离群值
    nonOutlierData = data(data >= lowerWhisker & data <= upperWhisker);
    % 计算非离群值的最小值和最大值
    minNonOutlier = min(nonOutlierData);
    maxNonOutlier = max(nonOutlierData);
end

