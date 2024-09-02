%theta

fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Fz','fatigue_Fz','recovered_Fz'};

% 初始化一個儲存所有狀態Theta波的變量
theta_data = [];

for data_files = 1:length(data_list)
    list = dir(fullfile(fpath, '**', '體動移除', [data_list{data_files} '.mat'])); % 查找所有符合条件的文件
    for j = 1:length(list)
        fileName = fullfile(list(j).folder, list(j).name); % 構建完整路徑
        loaded_data = load(fileName);
        if j == 1
            total_ps = loaded_data.ps;
            t_stft = loaded_data.t_stft;
            f = loaded_data.f;
        else
            total_ps = total_ps + loaded_data.ps;
        end
    end
    total_ps = total_ps / length(list);

    % 定義Theta波段範圍
    theta_range = [4 8];

    % 找到對應的頻率索引
    theta_indices = find(f >= theta_range(1) & f <= theta_range(2));

    % 提取Theta波的功率譜並進行平滑處理
    theta_ps = smoothdata(sum(abs(total_ps(theta_indices, :)), 1), 'gaussian', 5);
    
    % 儲存當前狀態的Theta波數據
    theta_data = [theta_data; theta_ps];
end

% 創建一個圖形並使用subplot繪製由上而下排列的三個子圖
figure;

% 第一個子圖：Base狀態的Theta波
subplot(3,1,1);
plot(t_stft/60, theta_data(1, :), 'LineWidth', 1.5); 
xlabel('Time (min)');
ylabel('Theta Power');
title('Base State - Theta Wave at Fz');
ylim([0, 300]);

% 第二個子圖：Fatigue狀態的Theta波
subplot(3,1,2);
plot(t_stft/60, theta_data(2, :), 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Theta Power');
title('Fatigue State - Theta Wave at Fz');
ylim([0, 300]);

% 第三個子圖：Recovered狀態的Theta波
subplot(3,1,3);
plot(t_stft/60, theta_data(3, :), 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Theta Power');
title('Recovered State - Theta Wave at Fz');
ylim([0, 300]);

% 調整圖形大小和佈局
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 15]);

% 保存圖形
saveas(gcf, fullfile(fpath, 'images\Fz_Theta_Comparison_Subplots.png'));
