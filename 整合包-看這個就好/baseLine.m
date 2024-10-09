save_switch = 1;

channel = {'Cz','Fz'};
fpath = [uigetdir(pwd, 'Select a folder') ];

new_path = [fpath '\波型比較'];
if save_switch == 1
    mkdir(new_path);
end

for index = 1:length(channel)
%data_info 內為 ps,t_stft,f
file_list = {[ channel{index} '_base.mat'],[ channel{index} '_fatigue.mat'],[channel{index} '_recovered.mat']};
data_info = cell(3);


for file = 1:length(file_list)
    load_data = load([fpath '\體動移除\' file_list{file}]);
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

bands_baseline = cell(length(bands),1);


for band = 1:3  % 1: alpha, 2: beta, 3: theta
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
        ps = mean(abs(data_info{1, state}(indices, :)), 1);
        if band == 2
            test = ps;
        end
        if state == 1
        mean_ps = mean(ps);
        bands_baseline{band,1} = mean_ps;
             % BASE
            % [alpha]平均
            % [beta ]平均
            % [theta]平均
        end
        ps = ps/bands_baseline{band,1};
    end

    if save_switch == 1
        save([fpath '\' channel{index} '_bands_baseline.mat'], 'bands_baseline');
    end
    
end
% clearvars -except save_switch channel fpath new_path bands_baseline;
end

