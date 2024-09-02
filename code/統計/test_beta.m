%beta

fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Fz','fatigue_Fz','recovered_Fz'};

% 初始化一個儲存所有狀態Beta波的變量
beta_data = [];

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

    % 定義Beta波段範圍
    beta_range = [12 35];

    % 找到對應的頻率索引
    beta_indices = find(f >= beta_range(1) & f <= beta_range(2));

    % 提取Beta波的功率譜並進行平滑處理
    beta_ps = smoothdata(sum(abs(total_ps(beta_indices, :)), 1), 'gaussian', 5);
    
    % 儲存當前狀態的Beta波數據
    beta_data = [beta_data; beta_ps];
end

% 創建一個圖形並使用subplot繪製由上而下排列的三個子圖
figure;

% 第一個子圖：Base狀態的Beta波
subplot(3,1,1);
plot(t_stft/60, beta_data(1, :), 'LineWidth', 1.5);
xlabel('Time (min)');
ylabel('Beta Power');
title('Base State - Beta Wave at Fz');
ylim([0, 100]);

% 第二個子圖：Fatigue狀態的Beta波
subplot(3,1,2);
plot(t_stft/60, beta_data(2, :), 'LineWidth', 1.5); 
xlabel('Time (min)');
ylabel('Beta Power');
title('Fatigue State - Beta Wave at Fz');
ylim([0, 100]);

% 第三個子圖：Recovered狀態的Beta波
subplot(3,1,3);
plot(t_stft/60, beta_data(3, :), 'LineWidth', 1.5); 
xlabel('Time (min)');
ylabel('Beta Power');
title('Recovered State - Beta Wave at Fz');
ylim([0, 100]);

% 調整圖形大小和佈局
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 15]);

% 保存圖形
saveas(gcf, fullfile(fpath, 'images\Fz_Beta_Comparison_Subplots.png'));
