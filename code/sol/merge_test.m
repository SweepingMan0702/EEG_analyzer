fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Cz','fatigue_Cz','recovered_Cz','base_Fz','fatigue_Fz','recovered_Fz'};
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
% 定義波段範圍
 alpha_range = [8 12];
 beta_range = [12, 35];
 theta_range = [4, 7];
% 找到對應的頻率索引
 alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
 beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
 theta_indices = find(f >= theta_range(1) & f <= theta_range(2));
% 提取各波段的功率譜
 alpha_ps = squeeze(sum(abs(all_ps(alpha_indices, :, :)), 1));
 beta_ps = squeeze(sum(abs(all_ps(beta_indices, :, :)), 1));
 theta_ps = squeeze(sum(abs(all_ps(theta_indices, :, :)), 1));
% 计算每个波段的非离群值范围
 freq_bands = {alpha_ps(:), beta_ps(:), theta_ps(:)};
 band_names = {'Alpha (8-12 Hz)', 'Beta (12-35 Hz)', 'Theta (4-7 Hz)'};
for i = 1:length(freq_bands)
% 删除离群值
 [minNonOutlier, maxNonOutlier, nonOutlierData] = calculateNonOutlierRange(freq_bands{i});
% 绘制直方图
 figure;
 set(gcf, 'Units', 'Inches', 'Position', [0, 0, 8, 6]);
 histogram(nonOutlierData);
 xlabel('能量大小');
 ylabel('分布');
 title([data_list{data_files} ' - ' bandnames{i} ' Histogram']);
 grid on;
 xlim([minNonOutlier, maxNonOutlier]);
% 保存直方图图形
% saveas(gcf, fullfile(fpath, ['histogram' data_list{datafiles} '' band_names{i}(1:5) '.png']));
% 绘制箱型图
 figure;
 set(gcf, 'Units', 'Inches', 'Position', [0, 0, 8, 6]);
 boxchart(nonOutlierData);
 xlabel('能量大小');
 ylabel('分布');
 title([data_list{data_files} ' - ' bandnames{i} ' Boxplot']);
 grid on;
 ylim([minNonOutlier, maxNonOutlier]);
% 保存箱型图图形
% saveas(gcf, fullfile(fpath, ['boxplot' data_list{datafiles} '' band_names{i}(1:5) '.png']));
end
end
clearvars -except data_vars files signal turns ch path1;
disp('已將各圖檔儲存至資料夾內');
% 箱型圖範圍函式
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