% 教學範例：生成樣本波型並通過帶通濾波器
% 1. 取樣頻率 Fs = 250
% 2. 產生一個樣本波型
%    - 0到2秒: 5Hz 振幅3 + 8Hz 振幅5 + 17Hz 振幅2 的複合波型
%    - 3到5秒: 8Hz 振幅3 + 17Hz 振幅7 的複合波型
% 3. 設計3個帶通濾波器，頻帶分別為 4-6Hz, 6-9Hz 以及 15-20Hz
% 4. 將波型分別經過這三個濾波器濾波後，繪圖呈現
% 5. 計算濾波結果的功率 (abs^2)，並以0.1秒的moving average繪圖呈現

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
         'HalfPowerFrequency1',4,'HalfPowerFrequency2',6, ...
         'SampleRate',Fs);

bpFilt2 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',6,'HalfPowerFrequency2',9, ...
         'SampleRate',Fs);

bpFilt3 = designfilt('bandpassiir','FilterOrder',4, ...
         'HalfPowerFrequency1',15,'HalfPowerFrequency2',20, ...
         'SampleRate',Fs);

% 將波型經過濾波器
y1 = filtfilt(bpFilt1, x);
y2 = filtfilt(bpFilt2, x);
y3 = filtfilt(bpFilt3, x);

% 繪製濾波後的波型
figure;
subplot(3,1,1);
plot(t, y1);
title('4-6 Hz 帶通濾波後的波型');
xlabel('時間 (秒)');
ylabel('振幅');
grid on;

subplot(3,1,2);
plot(t, y2);
title('6-9 Hz 帶通濾波後的波型');
xlabel('時間 (秒)');
ylabel('振幅');
grid on;

subplot(3,1,3);
plot(t, y3);
title('15-20 Hz 帶通濾波後的波型');
xlabel('時間 (秒)');
ylabel('振幅');
grid on;

% 計算濾波結果的功率 (abs^2)
power1 = abs(y1).^2;
power2 = abs(y2).^2;
power3 = abs(y3).^2;

% 計算0.1秒的移動平均
window_size = 0.1 * Fs; % 0.1秒對應的樣本數
mov_avg_power1 = movmean(power1, window_size);
mov_avg_power2 = movmean(power2, window_size);
mov_avg_power3 = movmean(power3, window_size);

% 繪製功率譜 (abs^2) 和移動平均
figure;
subplot(3,1,1);
plot(t, mov_avg_power1);
title('4-6 Hz 帶通濾波後的功率譜 (0.1秒移動平均)');
xlabel('時間 (秒)');
ylabel('功率');
grid on;

subplot(3,1,2);
plot(t, mov_avg_power2);
title('6-9 Hz 帶通濾波後的功率譜 (0.1秒移動平均)');
xlabel('時間 (秒)');
ylabel('功率');
grid on;

subplot(3,1,3);
plot(t, mov_avg_power3);
title('15-20 Hz 帶通濾波後的功率譜 (0.1秒移動平均)');
xlabel('時間 (秒)');
ylabel('功率');
grid on;
