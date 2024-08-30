% 載入三個狀態的數據
base_data = load('base_Cz_combined.mat');
fatigue_data = load('fatigue_Cz_combined.mat');
recovered_data = load('recovered_Cz_combined.mat');

% 假設每個文件中的ps數據存儲在名為'ps'的變量中
base_ps = base_data.total_ps;
fatigue_ps = fatigue_data.total_ps;
recovered_ps = recovered_data.total_ps;

% 定義頻率範圍
f = base_data.f;  % 假設頻率向量存儲在f變量中
alpha_range = [8 12];
beta_range = [12, 35];
theta_range = [4, 7];


% 處理每個狀態的數據
X_base = process_state_data(base_ps, f, alpha_range, beta_range, theta_range);
X_fatigue = process_state_data(fatigue_ps, f, alpha_range, beta_range, theta_range);
X_recovered = process_state_data(recovered_ps, f, alpha_range, beta_range, theta_range);

% 繪製空間分布圖
figure;
hold on;
scatter3(X_base(:,1), X_base(:,2), X_base(:,3), 10, 'b', 'filled');
scatter3(X_fatigue(:,1), X_fatigue(:,2), X_fatigue(:,3), 10, 'r', 'filled');
scatter3(X_recovered(:,1), X_recovered(:,2), X_recovered(:,3), 10, 'g', 'filled');

xlabel('Alpha Power');
ylabel('Beta Power');
zlabel('Theta Power');
title('狀態分布圖');
legend('Base', 'Fatigue', 'Recovered', 'Location', 'bestoutside');

view(45, 30);
grid on;
rotate3d on;
saveas(gcf,'scatter_Cz.png');

% 合併所有數據以進行K-means分群
X_combined = [X_base; X_fatigue; X_recovered];

% 進行K-means分群
k = 3;  % 設置群集數量

% 嘗試使用 kmeans 函數，並添加錯誤處理
try
    [idx, centroids] = kmeans(X_combined, k);
catch ME
    % 如果發生錯誤，顯示錯誤信息並嘗試提供解決方案
    fprintf('Error using kmeans function: %s\n', ME.message);
    fprintf('Troubleshooting steps:\n');
    fprintf('1. Make sure Statistics and Machine Learning Toolbox is installed.\n');
    fprintf('2. Check if there is a local file named kmeans.m in your working directory.\n');
    fprintf('3. Try using the full path to the MATLAB kmeans function:\n');
    fprintf('   [idx, centroids] = matlab.stats.cluster.kmeans(X_combined, k);\n');
    fprintf('4. If the problem persists, please check your MATLAB version and toolbox installations.\n');
    % 如果錯誤持續，可以在這裡添加替代的聚類方法
    error('Unable to perform k-means clustering. Please follow the troubleshooting steps above.');
end

% 創建新的圖形窗口用於K-means結果
figure;
colors = ['b', 'r', 'g'];
marker_sizes = [10, 10, 10];  % 為每個集群定義不同的點大小

for i = 1:k
    cluster_points = X_combined(idx == i, :);
    scatter3(cluster_points(:,1), cluster_points(:,2), cluster_points(:,3), marker_sizes(i), colors(i), 'filled');
    hold on;
end

% 繪製群集中心
scatter3(centroids(:,1), centroids(:,2), centroids(:,3), 100, 'k', 'x', 'LineWidth', 2);

xlabel('Alpha Power');
ylabel('Beta Power');
zlabel('Theta Power');
title('K-means 分群結果');

legend_entries = {sprintf('Cluster 1'), ...
                  sprintf('Cluster 2'), ...
                  sprintf('Cluster 3'), ...
                  'Centroids'};
legend(legend_entries, 'Location', 'bestoutside');

view(45, 30);
grid on;
rotate3d on;
saveas(gcf,'kmeans_Cz.png');


% 定義一個函數來處理每個狀態的數據
function X = process_state_data(ps, f, alpha_range, beta_range, theta_range)
    % 找到相應頻率範圍的索引
    alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
    beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
    theta_indices = find(f >= theta_range(1) & f <= theta_range(2));

    % 提取各波段的功率譜
    alpha_ps = ps(alpha_indices, :);
    beta_ps = ps(beta_indices, :);
    theta_ps = ps(theta_indices, :);

    % 計算各波段的總功率
    A = sum(alpha_ps, 1);
    B = sum(beta_ps, 1);
    T = sum(theta_ps, 1);

    X = [A; B; T]';

    % 移除離群值
    Q1 = quantile(X, 0.25);
    Q3 = quantile(X, 0.75);
    IQR = Q3 - Q1;
    lower_bound = Q1 - 1.5 * IQR;
    upper_bound = Q3 + 1.5 * IQR;
    valid_rows = all(X >= lower_bound & X <= upper_bound, 2);
    X = X(valid_rows, :);
end