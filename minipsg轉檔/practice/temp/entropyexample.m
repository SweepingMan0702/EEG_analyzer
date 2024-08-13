% 教學範例：生成樣本波型並通過帶通濾波器
% 1. 取樣頻率 Fs = 250
% 2. 產生一個樣本波型
%    - 0到2秒: 5Hz 振幅3 + 8Hz 振幅5 + 17Hz 振幅2 的複合波型
%    - 3到5秒: 8Hz 振幅3 + 17Hz 振幅7 的複合波型
% 3. 設計3個帶通濾波器，頻帶分別為 4-6Hz, 6-9Hz 以及 15-20Hz
% 4. 將波型分別經過這三個濾波器濾波後，繪圖呈現
% 5. 計算濾波結果的每250點熵，並繪圖呈現

%clear all;
%close all;

x = data(2,:);

% 參數設置
Fs = 250; % 取樣頻率 (Hz)
T = 1/Fs; % 取樣周期 (秒)
N = length(x);% 數據點數
t_total = (N-1) * T; % 總時間 (秒)
t = (0:T:t_total)/60; % 時間向量

% 繪製原始波型
figure;
plot(t, x);
title('原始樣本波型');
xlabel('時間 (分鐘)');
ylabel('振幅');
grid on;

% 設計帶通濾波器

bpFilt1 = designfilt('bandpassiir','FilterOrder',4, ...
 'HalfPowerFrequency1',8,'HalfPowerFrequency2',12, ...
'SampleRate',Fs);

bpFilt2 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',12,'HalfPowerFrequency2',35, ...
         'SampleRate',Fs);

bpFilt3 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',4,'HalfPowerFrequency2',7, ...
         'SampleRate',Fs);

% 將波型經過濾波器
y1 = filtfilt(bpFilt1, x);
y2 = filtfilt(bpFilt2, x);
y3 = filtfilt(bpFilt3, x);

% 繪製濾波後的波型
figure;
%subplot(3,1,1);
plot(t, abs(y1));
%(Alpha波)
title('8-12 Hz 帶通濾波後的波型(Alpha波)');
xlabel('時間 (分鐘)');
ylabel('振幅');
grid on;

figure;
%subplot(3,1,2);
plot(t, abs(y2));
%(Beta波)
title('12-35 Hz 帶通濾波後的波型(Beta波)');
xlabel('時間 (分鐘)');
ylabel('振幅');
grid on;

figure;
%subplot(3,1,3);
plot(t, abs(y3));
%(Theta波)
title('4-7 Hz 帶通濾波後的波型(Theta波)');
xlabel('時間 (分鐘)');
ylabel('振幅');
grid on;

% % 計算每250點的熵
% window_size = 250;
% entropy1 = zeros(1, length(y1) - window_size + 1);
% entropy2 = zeros(1, length(y2) - window_size + 1);
% entropy3 = zeros(1, length(y3) - window_size + 1);
% 
% for i = 1:length(entropy1)
%     window = y1(i:i + window_size - 1);
%     prob = histcounts(window, 'Normalization', 'probability');
%     prob(prob == 0) = [];
%     entropy1(i) = -sum(prob .* log2(prob));
% end
% 
% for i = 1:length(entropy2)
%     window = y2(i:i + window_size - 1);
%     prob = histcounts(window, 'Normalization', 'probability');
%     prob(prob == 0) = [];
%     entropy2(i) = -sum(prob .* log2(prob));
% end
% 
% for i = 1:length(entropy3)
%     window = y3(i:i + window_size - 1);
%     prob = histcounts(window, 'Normalization', 'probability');
%     prob(prob == 0) = [];
%     entropy3(i) = -sum(prob .* log2(prob));
% end
% 
% % 繪製熵圖
% t_entropy = t(1:length(entropy1));
% 
% figure;
% subplot(3,1,1);
% plot(t_entropy, entropy1);
% %(Alpha波)
% title('8-12 Hz 帶通濾波後的熵(Alpha波)');
% xlabel('時間 (分鐘)');
% ylabel('熵');
% grid on;
% 
% subplot(3,1,2);
% plot(t_entropy, entropy2);
% %(Beta波)
% title('12-35 Hz 帶通濾波後的熵');
% xlabel('時間 (分鐘)');
% ylabel('熵');
% grid on;
% 
% subplot(3,1,3);
% plot(t_entropy, entropy3);
% %(Theta波)
% title('4-7 Hz 帶通濾波後的熵');
% xlabel('時間 (分鐘)');
% ylabel('熵');
% grid on;
