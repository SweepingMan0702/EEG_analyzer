%選擇以日期命名的資料夾
%顯示出各states的bands比較
save_switch = 0;

channel = {'Cz','Fz'};
fpath = [uigetdir(pwd, 'Select a folder') '\體動移除\'];

for index = 1:length(channel)
%data_info 內為 ps,t_stft,f
file_list = {['base_' channel{index} '.mat'],['fatigue_' channel{index} '.mat'],['recovered_' channel{index} '.mat']};
data_info = cell(3);

for file = 1:length(file_list)
    load_data = load([fpath file_list{file}]);
    data_info{1,file} = load_data.ps;
    data_info{2,file} = load_data.t_stft;
    data_info{3,file} = load_data.f;
    clear load_data;
end

alpha_range = [8 12];
beta_range = [12, 35];
theta_range = [4, 7];
freq_range = {alpha_range,beta_range,theta_range};
color_list = {'r','g','b'};
state_names = {'Base', 'Fatigue', 'Recovered'};
bands = {'α','β','θ'};

for band = 1:3  % 1: alpha, 2: beta, 3: theta
    figure;
    hold on;
    switch band
        case 1
            freq_range = alpha_range;
            band_name = 'Alpha';
        case 2
            freq_range = beta_range;
            band_name = 'Beta';
        case 3
            freq_range = theta_range;
            band_name = 'Theta';
    end
    
    for state = 1:length(file_list)
        % 找到对应的频率索引
        indices = find(data_info{3, state} >= freq_range(1) & data_info{3, state} <= freq_range(2));
        
        % 计算功率谱并平滑
        ps = smoothdata(mean(abs(data_info{1, state}(indices, :)), 1), 'gaussian', 5);
     
        % 绘制
        plot(data_info{2, state}/60, ps, color_list{state}, 'LineWidth', 2);
    end
    legend('Base', 'fatigue', 'recovered');
    % 添加图形标签和标题
    xlabel('Time (min)');
    ylabel('Power');
    title([channel{index} ' - ' bands{band} ' - compare']);
    
    % 调整图形
    grid on;
    axis tight;
    
    % 调整图形大小以适应图例
    set(gcf, 'Position', get(0, 'Screensize'));
    pic_path = fullfile(fpath , [band_name '_compare.png']);

    if save_switch == 1
        saveas(gcf,pic_path);
        close all;
    end
    
end
clearvars -except save_switch channel fpath;
end

