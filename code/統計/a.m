%繪製折線圖並平滑化處理

fpath = uigetdir(pwd, 'Select a folder');
data_list = {'base_Cz','fatigue_Cz','recovered_Cz','base_Fz','fatigue_Fz','recovered_Fz'};
for data_files = 1:length(data_list)
 list = dir(fullfile(fpath, '**', '體動移除', [data_list{data_files} '.mat'])); % 查找所有符合条件的文件
for j = 1:length(list)
 fileName = fullfile(list(j).folder, list(j).name); % 构建完整路径
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
% 定義波段範圍
 alpha_range = [8 12];
 beta_range = [12, 35];
 theta_range = [4, 7];
% 找到對應的頻率索引
 alpha_indices = find(f >= alpha_range(1) & f <= alpha_range(2));
 beta_indices = find(f >= beta_range(1) & f <= beta_range(2));
 theta_indices = find(f >= theta_range(1) & f <= theta_range(2));
% 提取各波段的功率譜並進行平滑處理
 alpha_ps = smoothdata(sum(abs(total_ps(alpha_indices, :)), 1), 'gaussian', 5);
 beta_ps = smoothdata(sum(abs(total_ps(beta_indices, :)), 1), 'gaussian', 5);
 theta_ps = smoothdata(sum(abs(total_ps(theta_indices, :)), 1), 'gaussian', 5);
% 創建一個新的圖形，包含三個子圖
 figure;
% Alpha波子圖
 subplot(3,1,1);
 plot(t_stft/60, alpha_ps);
 xlabel('Time (min)');
 ylabel('Alpha Power');
 title([data_list{data_files} ' - Alpha Wave']);
 ylim([0, 100]);
% Beta波子圖
 subplot(3,1,2);
 plot(t_stft/60, beta_ps);
 xlabel('Time (min)');
 ylabel('Beta Power');
 title([data_list{data_files} ' - Beta Wave']);
 ylim([0, 100]);
% Theta波子圖
 subplot(3,1,3);
 plot(t_stft/60, theta_ps);
 xlabel('Time (min)');
 ylabel('Theta Power');
 title([data_list{data_files} ' - Theta Wave']);
 ylim([0, 100]);
% 調整整個圖形的大小和佈局
 set(gcf, 'Units', 'Inches', 'Position', [0, 0, 16, 15]);
 sgtitle([data_list{data_files} ' - EEG Wave Analysis'], 'FontSize', 16);
% 保存圖形
% saveas(gcf, fullfile(fpath, ['images\', data_list{data_files}, '_EEG_waves.png']));
end