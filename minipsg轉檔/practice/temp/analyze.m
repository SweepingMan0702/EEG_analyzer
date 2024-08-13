%data的第一row ,":"取所有
x = data(1,:);
%窗長 : 設數點的個數
%重疊 : 兩個相鄰窗重疊數據點的個數
%採樣時間 250points/s

%可以點APP裡的signal analyzer

% 變數 = spectrogram(資料);
s = spectrogram(x); %默認將數據切為8段
spectrogram(x); %直接畫

% s = spectrogram(x,window)
s = spectrogram(x,128);
%切成 (N-W/2)/(W/2) + 1 段

% s = spectrogram(x,window,重疊數據點)
s = spectrogram(x,128,120);

% s = spectrogram(x,window,noverlap,傅立葉長度)
s = spectrogram(x,128,120,128);

% [s,w,t] = spectrogram(x,window,noverlap,nfft)
[s,w,t] = spectrogram(x,128,120,128);


%回傳能量power spectral
[~,fx,tx,ps] = spectrogram(x,window,noverlap,fs,"power")

%回傳能量密度power spectral density(單位時間的平均振幅)
[~,fx,tx,psd] = spectrogram(x,window,noverlap,f,"psd")


clear all;
% 生成一個示例信號
% fs = 1000;  % 採樣頻率
% t = 0:1/fs:1-1/fs;  % 時間向量
% x = sin(2*pi*100*t) + 0.5*sin(2*pi*200*t);  % 包含兩個頻率的信號
% 
% 設置 spectrogram 參數
% window = hamming(256);  % 使用 Hamming 窗
% noverlap = 128;  % 50% 重疊


x = data(2,:);

% 參數設置
fs = 250; % 取樣頻率 (Hz)
T = 1/fs; % 取樣周期 (秒)
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

% 計算並繪製 STFT
window = hamming(256);     % 使用 Hamming 窗口
noverlap = 128;         % 重疊部分
nfft = 512;             % FFT 點數


% 計算功率譜
[~,fx,tx,ps] = spectrogram(x,window,noverlap,fs,"power");

% 計算功率譜密度
[~,fx,tx,psd] = spectrogram(x,window,noverlap,fs,"psd");

% 繪製功率譜
figure;
surf(tx,fx,10*log10(ps),'EdgeColor','none');
axis tight;
view(0,90);
xlabel('時間 (秒)');
ylabel('頻率 (Hz)');
title('功率譜');
colorbar;

% 繪製功率譜密度
figure;
surf(tx,fx,10*log10(psd),'EdgeColor','none');
axis tight;
view(0,90);
xlabel('時間 (秒)');
ylabel('頻率 (Hz)');
title('功率譜密度');
colorbar;



