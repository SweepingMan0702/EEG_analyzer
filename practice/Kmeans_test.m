x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

% 定義兩個時間範圍
time_ranges = [
    0 * 60, 3 * 60;  % 第一個時間範圍（秒）
    25 * 60, 30 * 60   % 第二個時間範圍（秒）
];

% 初始化存儲結果的cell陣列
results = cell(3, 1);

for i = 1:size(time_ranges, 1)
    % 設置要擷取的時間範圍
    start_time = time_ranges(i, 1);
    end_time = time_ranges(i, 2);

    % 擷取指定時間段的數據
    start_sample = round(start_time * fs) + 1;
    end_sample = round(end_time * fs);
    working_x = x(start_sample:end_sample);

    [~, f, t_stft, ps] = spectrogram(working_x, win, noverlap, nfft, fs, "ps");

    % 定義和提取各波段的功率譜
    alpha_range = [8 12];
    beta_range = [12, 35];
    theta_range = [4, 7];

    alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
    beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
    theta_indices = find(f >= theta_range(1) & f <= theta_range(2));

    alpha_ps = ps(alpha_indices, :);
    beta_ps = ps(beta_indices, :);
    theta_ps = ps(theta_indices, :);

    A = sum(alpha_ps, 1);
    B = sum(beta_ps, 1);
    T = sum(theta_ps, 1);

    X = [A; B; T]';

    % 離群值刪除
    Q1 = quantile(X, 0.25);
    Q3 = quantile(X, 0.75);
    IQR = Q3 - Q1;
    lower_bound = Q1 - 1.5 * IQR;
    upper_bound = Q3 + 1.5 * IQR;
    valid_rows = all(X >= lower_bound & X <= upper_bound, 2);
    X_cleaned = X(valid_rows, :);

    % 存儲結果
    results{i} = X_cleaned;

    % 顯示處理進度
    fprintf('已處理時間段 %d: %.1f 分鐘 到 %.1f 分鐘\n', i, start_time/60, end_time/60);
end

% 讀取和處理新檔案的數據
new_file = 'recovered.mat';  % 替換為新檔案的實際名稱
new_data = load(new_file);  % 載入新檔案
new_x = new_data.data(2,:);  % 假設新數據結構與原始數據相同

% 設置新檔案的時間範圍（例如：10-15分鐘）
new_start_time = 0 * 60;  % 開始時間（秒）
new_end_time = 5 * 60;    % 結束時間（秒）

% 擷取新檔案指定時間段的數據
new_start_sample = round(new_start_time * fs) + 1;
new_end_sample = round(new_end_time * fs);
new_working_x = new_x(new_start_sample:new_end_sample);

% 處理新檔案的數據
[~, f, ~, new_ps] = spectrogram(new_working_x, win, noverlap, nfft, fs, "ps");

% 定義和提取各波段的功率譜
alpha_range = [8 12];
beta_range = [12, 35];
theta_range = [4, 7];

alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
theta_indices = find(f >= theta_range(1) & f <= theta_range(2));

new_alpha_ps = new_ps(alpha_indices, :);
new_beta_ps = new_ps(beta_indices, :);
new_theta_ps = new_ps(theta_indices, :);

new_A = sum(new_alpha_ps, 1);
new_B = sum(new_beta_ps, 1);
new_T = sum(new_theta_ps, 1);

new_X = [new_A; new_B; new_T]';

% 離群值刪除（對新數據）
Q1 = quantile(new_X, 0.25);
Q3 = quantile(new_X, 0.75);
IQR = Q3 - Q1;
lower_bound = Q1 - 1.5 * IQR;
upper_bound = Q3 + 1.5 * IQR;
valid_rows = all(new_X >= lower_bound & new_X <= upper_bound, 2);
new_X_cleaned = new_X(valid_rows, :);

% 存儲新檔案的結果
results{3} = new_X_cleaned;


% 合併兩個時間段的結果
X_combined = vertcat(results{:});

% 顯示結果
fprintf('合併後的數據大小: %d x %d\n', size(X_combined, 1), size(X_combined, 2));

% 可視化兩個時間段的結果
figure;

% 繪製第一個時間段的數據（使用藍色）
scatter3(results{1}(:,1), results{1}(:,2), results{1}(:,3), 20, 'b', 'filled');
hold on;

% 繪製第二個時間段的數據（使用紅色）
scatter3(results{2}(:,1), results{2}(:,2), results{2}(:,3), 20, 'r', 'filled');
scatter3(results{3}(:,1), results{3}(:,2), results{3}(:,3), 20, 'y', 'filled');
xlabel('Alpha Power');
ylabel('Beta Power');
zlabel('Theta Power');
title('狀態分布圖');

% 添加圖例
legend('base', 'fatigue','recovered' , 'Location', 'bestoutside');

% 調整視角和其他設置
view(45, 30);
grid on;
rotate3d on;



% 進行 K-means 分群
k = 3;  % 設置群集數量，您可以根據需要調整
[idx, centroids] = kmeans(X_combined, k);
% 創建一個新的圖形窗口
figure;
% 使用不同顏色繪製每個群集
colors = ['r','b','y','g', 'c', 'm'];  % 定義顏色，以防 k > 3
for i = 1:k
    cluster_points = X_combined(idx == i, :);
    scatter3(cluster_points(:,1), cluster_points(:,2), cluster_points(:,3), 30, colors(i), 'filled');
    hold on;
end
% 繪製群集中心
scatter3(centroids(:,1), centroids(:,2), centroids(:,3), 50, 'k', 'x', 'LineWidth', 2);
xlabel('Alpha Power');
ylabel('Beta Power');
zlabel('Theta Power');
title('K-means 分群');
% 創建圖例
legend_entries = cell(k + 1, 1);
for i = 1:k
    legend_entries{i} = sprintf('Cluster %d', i);
end
legend_entries{k + 1} = 'Centroids';
legend(legend_entries, 'Location', 'bestoutside');
view(45, 30);
grid on;
rotate3d on;
