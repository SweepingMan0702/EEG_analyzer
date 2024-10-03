function [minNonOutlier, maxNonOutlier , nonOutlierData] = calculateNonOutlierRange(data)
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