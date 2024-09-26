%Cz的統計盒方圖、長條圖

fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Cz','fatigue_Cz','recovered_Cz'};
band_names = {'Alpha (8-12 Hz)', 'Beta (12-35 Hz)', 'Theta (4-7 Hz)'};
figure_index = 1;

for i = 1:length(band_names)
    figure; % 创建一个新的图形窗口
    for data_files = 1:length(data_list)
        list = dir(fullfile(fpath, '**', '體動移除', [data_list{data_files} '.mat'])); % 查找所有符合条件的文件
        all_ps = [];
        for j = 1:length(list)
            fileName = fullfile(list(j).folder, list(j).name); % 构建完整路径
            loaded_data = load(fileName);
            all_ps = cat(3, all_ps, loaded_data.ps);
            if j == 1
                t_stft = loaded_data.t_stft;
                f = loaded_data.f;
            end
        end
        
        % 定义波段范围
        alpha_range = [8 12];
        beta_range = [12, 35];
        theta_range = [4, 7];
        
        % 找到对应的频率索引
        alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
        beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
        theta_indices = find(f >= theta_range(1) & f <= theta_range(2));
        
        % 提取各波段的功率谱
        alpha_ps = squeeze(sum(abs(all_ps(alpha_indices, :, :)), 1));
        beta_ps = squeeze(sum(abs(all_ps(beta_indices, :, :)), 1));
        theta_ps = squeeze(sum(abs(all_ps(theta_indices, :, :)), 1));
        
        % 计算每个波段的非离群值范围
        freq_bands = {alpha_ps(:), beta_ps(:), theta_ps(:)};
        
        % 删除离群值并绘制直方图和箱型图
        [minNonOutlier, maxNonOutlier, nonOutlierData] = calculateNonOutlierRange(freq_bands{i});
        
        % 绘制直方图
        subplot(2, 3, data_files); % 将三种状态的直方图绘制在同一个图形窗口中
        histogram(nonOutlierData);
        xlabel('能量大小');
        ylabel('分布');
        title([data_list{data_files} ' - ' band_names{i} ' Histogram']);
        grid on;
        set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);

        % 绘制箱型图
        subplot(2, 3, data_files + 3); % 将三种状态的箱型图绘制在同一个图形窗口中
        boxchart(nonOutlierData);
        xlabel('能量大小');
        ylabel('分布');
        title([data_list{data_files} ' - ' band_names{i} ' Boxplot']);
        grid on;
        ylim([minNonOutlier, maxNonOutlier]);
        set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 9]);
    end
    
    % 保存图形
    saveas(gcf, fullfile(fpath, ['\Cz\comparison_' band_names{i}(1:5) '.png']));
end

disp('已將各圖檔儲存至資料夾內');

% 箱型图范围函数
function [minNonOutlier, maxNonOutlier, nonOutlierData] = calculateNonOutlierRange(data)
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
