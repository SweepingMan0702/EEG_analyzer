x = data(2,:);
fs = 250;
win = hamming(250);
noverlap = 125;
nfft = 256;

% 設置要擷取的時間範圍
start_time = 3 * 60;  % 開始時間（秒）
end_time = 23 * 60;    % 結束時間（秒）

% % 擷取指定時間段的數據
% start_sample = round(start_time * fs) + 1;
% end_sample = round(end_time * fs);
% working_x = x(start_sample:end_sample);


[~, f, t_stft, ps] = spectrogram(x, win, noverlap, nfft, fs, "ps");
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
close all;

A = sum(alpha_ps,1);
B = sum(beta_ps,1);
T = sum(theta_ps,1);
X = [A ;B ;T]';

% 假設您的數據已經載入到變量 X 中，大小為 3741x3
% 如果還沒有，您可以這樣載入：
% load('your_data_file.mat'); % 替換成您的數據文件名

% 檢查數據大小
[num_samples, num_features] = size(X);
fprintf('數據大小: %d 樣本, %d 特徵\n', num_samples, num_features);

% 設置聚類數量（可以根據需要調整）
k = 3;

% 執行 K-means 聚類
[idx, centroids] = kmeans(X, k);

% 創建 3D 散點圖
figure;
scatter3(X(:,1), X(:,2), X(:,3), 15, idx, 'filled');
hold on;

% 添加聚類中心
plot3(centroids(:,1), centroids(:,2), centroids(:,3), 'kx', 'MarkerSize', 15, 'LineWidth', 3);

% 添加標籤和標題
xlabel('特徵 1');
ylabel('特徵 2');
zlabel('特徵 3');
title('3D K-means 聚類結果');

% 添加顏色條以顯示聚類
colorbar;

% 添加圖例
legend('數據點', '聚類中心', 'Location', 'bestoutside');

% 調整視角以獲得更好的視圖
view(45, 30);

% 添加網格線以增強 3D 效果
grid on;

% 顯示每個聚類的樣本數
for i = 1:k
    cluster_size = sum(idx == i);
    fprintf('聚類 %d: %d 個樣本\n', i, cluster_size);
end