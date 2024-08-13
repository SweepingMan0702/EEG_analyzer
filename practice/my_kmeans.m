function [idx, centroids] = my_kmeans(X, k, max_iters)
    % X: 輸入數據, 每行是一個樣本
    % k: 聚類數量
    % max_iters: 最大迭代次數
    
    % 初始化
    [n, d] = size(X);
    centroids = X(randperm(n, k), :);
    
    for iter = 1:max_iters
        % 分配
        distances = pdist2(X, centroids);
        [~, idx] = min(distances, [], 2);
        
        % 更新
        new_centroids = zeros(k, d);
        for i = 1:k
            if sum(idx == i) > 0
                new_centroids(i, :) = mean(X(idx == i, :));
            else
                new_centroids(i, :) = centroids(i, :);
            end
        end
        
        % 檢查收斂
        if all(new_centroids == centroids)
            break;
        end
        centroids = new_centroids;
    end
end