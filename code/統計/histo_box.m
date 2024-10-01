%將數據統計並繪製出直方圖&箱型圖
save_switch = 1;

channel = {'Cz','Fz'};
fpath = [uigetdir(pwd, 'Select a folder') '\'];

for index = 1:length(channel)
%data_info 內為 ps,t_stft,f
file_list = {['base_' channel{index} '_combined.mat'],['fatigue_' channel{index} '_combined.mat'],['recovered_' channel{index} '_combined.mat']};
data_info = cell(3);

for file = 1:length(file_list)
    load_data = load([fpath file_list{file}]);
    data_info{1,file} = load_data.total_ps;
    % data_info{2,file} = load_data.t_stft;
    data_info{3,file} = load_data.f;
    clear load_data;
end

alpha_range = [8 12];
beta_range = [12, 35];
theta_range = [4, 7];
freq_ranges = {alpha_range,beta_range,theta_range};
color_list = {'r','g','b'};
state_names = {'Base', 'Fatigue', 'Recovered'};
bands = {'α','β','θ'};


for band = 1:3  % 1: alpha, 2: beta, 3: theta
    figure;
    hold on;

    freq_range = freq_ranges{band};
    max = 0;

   %直方圖繪製
    for state = 1:length(file_list)
        % 找到对应的频率索引
        indices = find(data_info{3, state} >= freq_range(1) & data_info{3, state} <= freq_range(2));
        sum_ps = sum(abs(data_info{1, state}(indices, :)),1);

        %離群值移除
        [minNonOutlier, maxNonOutlier,nonOutlierData] = calculateNonOutlierRange(sum_ps);

        if max < maxNonOutlier
            max = maxNonOutlier;
        end

        subplot(1, 3, state);
        histogram(nonOutlierData);
        xlabel('能量大小'); ylabel('點個數');
        title([bands{band} ' --- ' state_names{state}]);
        grid on;
    end

    for state = 1:length(file_list)
        subplot(1, 3, state);
        % ylim([0 150]);
        % xlim([0 60]);
    end

    sgtitle([channel{index} '-' bands{band} '-histogram']);
    set(gcf, 'Position', get(0, 'Screensize'));
    pic_path = fullfile(fpath , [channel{index} '_' bands{band} '_histogram.png']);
    if save_switch == 1
        saveas(gcf,pic_path);
        close all;
    end


    figure;
    hold on;
    freq_range = freq_ranges{band};
    band_name = bands{band};

    for state = 1:length(file_list)
        % 找到对应的频率索引
        indices = find(data_info{3, state} >= freq_range(1) & data_info{3, state} <= freq_range(2));
        sum_ps = sum(abs(data_info{1, state}(indices, :)),1);

        %離群值移除
        [minNonOutlier, maxNonOutlier,nonOutlierData] = calculateNonOutlierRange(sum_ps);
        
        if max < maxNonOutlier
            max = maxNonOutlier;
        end

        subplot(1, 3, state);
        boxchart(sum_ps);
        title([bands{band} ' --- ' state_names{state}]);
        grid on;
    end

    for state = 1:length(file_list)
        subplot(1, 3, state);
        ylim([0 max]);
    end

    sgtitle([channel{index} '-' bands{band} '-boxchart']);
    set(gcf, 'Position', get(0, 'Screensize'));
    pic_path = fullfile(fpath , [channel{index} '_' bands{band} '_boxchart.png']);
    if save_switch == 1
        saveas(gcf,pic_path);
        close all;
    end
end
end