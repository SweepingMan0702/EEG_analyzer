save_switch = 0;
channel = {'Cz','Fz'};
fpath = [uigetdir(pwd, 'Select a folder') '\'];

% 引入必要的工具箱
if ~license('test', 'Statistics_Toolbox')
    error('This code requires the Statistics and Machine Learning Toolbox');
end

for index = 1:length(channel)
    % data_info 內為 ps,t_stft,f
    file_list = {['base_' channel{index} '_combined.mat'],['fatigue_' channel{index} '_combined.mat'],['recovered_' channel{index} '_combined.mat']};
    data_info = cell(3);
    
    % 創建特徵矩陣和標籤向量
    X = [];
    Y = [];
    
    for file = 1:length(file_list)
        load_data = load([fpath file_list{file}]);
        data_info{1,file} = load_data.total_ps;
        data_info{3,file} = load_data.f;
        
        % 提取特徵（使用所有頻率的能量作為特徵）
        features = data_info{1,file}';
        
        % 添加到特徵矩陣
        X = [X; features];
        
        % 創建對應的標籤
        labels = repmat(file, size(features, 1), 1);
        Y = [Y; labels];
        
        clear load_data;
    end
    
    % 將數據集分為訓練集和測試集
    cv = cvpartition(size(X,1),'HoldOut',0.3);
    idx = cv.test;
    X_train = X(~idx,:);
    Y_train = Y(~idx,:);
    X_test = X(idx,:);
    Y_test = Y(idx,:);
    
    % 訓練隨機森林模型
    rng(1); % 為了結果的可重複性
    num_trees = 100; % 可以根據需要調整
    rf_model = TreeBagger(num_trees, X_train, Y_train, 'OOBPrediction', 'On', ...
    'Method', 'classification', 'PredictorSelection', 'curvature', ...
    'OOBPredictorImportance', 'on');  % 添加這個參數
    % 在測試集上進行預測
    [Y_pred, scores] = predict(rf_model, X_test);
    Y_pred = str2double(Y_pred);
    
    % 計算準確率
    accuracy = sum(Y_pred == Y_test) / length(Y_test);
    
    % 創建混淆矩陣
    C = confusionmat(Y_test, Y_pred);
    
    % 繪製混淆矩陣
    figure;
    confusionchart(C, {'Base', 'Fatigue', 'Recovered'});
    title(['Confusion Matrix - ' channel{index}]);
    
    % 計算特徵重要性
    imp = rf_model.OOBPermutedPredictorDeltaError;
    
    % 繪製特徵重要性
    figure;
    bar(imp);
    title(['Feature Importance - ' channel{index}]);
    xlabel('Feature Index');
    ylabel('Importance');
    
    % 找出前10個最重要的特徵
    [sorted_imp, idx] = sort(imp, 'descend');
    top_10 = idx(1:min(10, length(idx)));
    
    % 在控制台輸出前10個最重要的特徵
    fprintf('Top 10 most important features:\n');
    for i = 1:length(top_10)
        fprintf('Feature %d: Importance %.4f\n', top_10(i), sorted_imp(i));
    end
    
    % 保存結果
    if save_switch == 1
        saveas(gcf, fullfile(fpath, [channel{index} '_feature_importance.png']));
    end
    
    % 輸出結果
    fprintf('Channel: %s\n', channel{index});
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);
    fprintf('Confusion Matrix:\n');
    disp(C);
end