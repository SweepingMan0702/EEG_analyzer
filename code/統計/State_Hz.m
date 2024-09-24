file_list = {'base_Cz.mat','fatigue_Cz.mat','recovered_Cz.mat'};
Cz_info = cell(3);

fpath = [uigetdir(pwd, 'Select a folder') '\體動移除\'];

for file = 1:length(file_list)
    load_data = load([fpath file_list{file}]);
    Cz_info{1,file} = load_data.ps;
    Cz_info{2,file} = load_data.t_stft;
    Cz_info{3,file} = load_data.f;
    clear load_data;
end

alpha_range = [8 12];
beta_range = [12, 35];
theta_range = [4, 7];
color_list = {'r','g','b:'};

figure;
hold on;
for state = 1:length(file_list)
% 找到对应的频率索引
 alpha_indices = find(Cz_info{3, state} >= alpha_range(1) & Cz_info{3, state} <= alpha_range(2));
 alpha_ps = smoothdata(mean(abs(Cz_info{1, state}(alpha_indices, :)), 1), 'gaussian', 5);
 plot(Cz_info{2, state}/60, alpha_ps, color_list{state}, 'LineWidth', 2);
end

legend('Base', 'fatigue', 'recovered');
% 添加图形标签和标题
xlabel('Time (min)');
ylabel('Alpha Power');
title('Alpha Wave Power Over Time for Different States');
w

% 找到對應的頻率索引
% beta_indices = find(Cz_info{} >= beta_range(1) & Cz_infoa <= beta_range(2));
% theta_indices = find(Cz_info{} >= theta_range(1) & Cz_infoa <= theta_range(2));
% 提取各波段的功率譜並進行平滑處理

% beta_ps = smoothdata(sum(mean(Cz_info{}(beta_indices, :)), 1), 'gaussian', 5);
% theta_ps = smoothdata(sum(mean(Cz_info{}(theta_indices, :)), 1), 'gaussian', 5);
