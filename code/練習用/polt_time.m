%畫圖用 將原始資料繪製折線圖並標出時間
x = data(2,:);
figure;
timepoint = (1:length(data(2,:)))/250;
plot(timepoint,x)