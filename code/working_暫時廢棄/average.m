%working用 暫時廢棄

x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

% 設置要擷取的時間範圍
start_time = 4 * 60;  % 開始時間（秒）
end_time = 23 * 60;    % 結束時間（秒）

% 擷取指定時間段的數據
start_sample = round(start_time * fs) + 1;
end_sample = round(end_time * fs);
working_x = x(start_sample:end_sample);


[~, f, t_stft, ps] = spectrogram(working_x, win, noverlap, nfft, fs, "ps");
% 定義alpha波範圍
alpha_range = [8 12];
alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));

% 提取alpha波的功率譜
alpha_ps = ps(alpha_indices, :);

% 繪製alpha波的摺線圖
figure;
plot(t_stft/60, sum(alpha_ps,1));
xlabel('Time (min)');
ylabel('Alpha Power');
title('Alpha Wave Power Over Time');
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
saveas(gcf, [ 'D:\桌面\EEG\EEG_analyzer\practice' '\working_alpha.png']);

% 定義Beta波範圍
beta_range = [12, 35];
beta_indices = find(f >= beta_range(1) & f <= beta_range(2));

% 提取Beta波的功率譜
beta_ps = ps(beta_indices, :);

% 繪製Beta波的摺線圖
figure;
plot(t_stft/60, sum(beta_ps,1));
xlabel('Time (min)');
ylabel('beta Power');
title('Beta Wave Power Over Time');
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
saveas(gcf, [ 'D:\桌面\EEG\EEG_analyzer\practice' '\working_beta.png']);


% 定義Theta波範圍
theta_range = [4, 7];
theta_indices = find(f >= theta_range(1) & f <= theta_range(2));

% 提取Theta波的功率譜
theta_ps = ps(theta_indices, :);

% 繪製Theta波的摺線圖
figure;
plot(t_stft/60, sum(theta_ps,1));
xlabel('Time (min)');
ylabel('Theta Power');
title('Theta Wave Power Over Time');
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
saveas(gcf, [ 'D:\桌面\EEG\EEG_analyzer\practice' '\working_theta.png']);
% close all;

A = sum(alpha_ps,1);
B = sum(beta_ps,1);
T = sum(theta_ps,1);
X = [A ;B ;T]';

% 計算每種波的開頭和結尾一分鐘的平均值
waves = {A, B, T};
wave_names = {'Alpha', 'Beta', 'Theta'};

for i = 1:1
    wave = waves{i};
    
    % 只保留 t_stft 小於 60 秒的數據
    time_mask_start = t_stft <= 60;
    wave_start = wave(time_mask_start);
    
    % 只保留 t_stft 大於等於最後 60 秒的數據
    time_mask_end = t_stft >= (max(t_stft)-60);
    wave_end = wave(time_mask_end);
    
    % 計算開頭一分鐘和結尾一分鐘的平均值
    start_avg = mean(wave_start);
    end_avg = mean(wave_end);
    
    % 計算斜率
    x1 = 4; % 開始時間為 4 分鐘
    x2 = 23; % 結束時間為 23 分鐘
    slope = (end_avg - start_avg) / (x2 - x1);
    
    % 顯示結果
    disp(['-----' wave_names{i} ' 波-----']);
    disp(['開頭一分鐘的平均值: ' num2str(start_avg)]);
    disp(['結尾一分鐘的平均值: ' num2str(end_avg)]);
    disp([wave_names{i} '_start到' wave_names{i} '_end的斜率: ' num2str(slope)]);
    disp(' ');
end