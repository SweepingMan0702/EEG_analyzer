%% Version History
%*******************************************
%20210805modify
%NFT->2chnoACC
%miniPSG->4ch+ACC(modified EEGEOG&EMGfilter)
%*******************************************
function  Ble_Transform()
[fname, fpath] = uigetfile('*.txt;*.txt','Select the Ble-file');

list={'2channel+G sensor','2channel no G sensor','4channel','4channel+G sensor'};
[indx,tf] = listdlg('ListString',list,'SelectionMode','single');

tic
ID=fopen([fpath  fname]);
data_t=textscan(ID,'%f');
fclose(ID);
toc
start=data_t{1};

%% 2channel no g sensor
if indx==2
    [CH1_output, CH2_output, CH1, CH2] = data152_transformers3_8(start);
    data=[CH1_output; CH2_output;CH1_output-CH2_output];
elseif indx==1
%% 2channel has gsensor
    [CH1_output, CH2_output,CH1,CH2,dataX,dataY,dataZ] = data144_transformers4_1( start);
    accdata=[dataX;dataY;dataZ];
%     save([fpath '\' fname(1:end-4) '_G_data.mat'],'data');
    
    data=[CH1_output; CH2_output;CH1_output-CH2_output];
    
%% 4channel no gsensor
elseif indx==3
    [CH1_output, CH2_output, CH3_output, CH4_output] = data232_transformers_4_channel( start);
    data=[CH1_output; CH2_output;CH3_output;CH4_output];

%% 4channel with gsensor  **testing**
elseif indx==4
    [ACCX,ACCY,ACCZ,CH1,CH1_output, CH2_output, CH3_output, CH4_output] = data232_transformers_4CHACC_4_2( start);
    data=[CH1_output; CH2_output; CH3_output; CH4_output];
    accdata=[ACCX; ACCY; ACCZ];
end

%% Filter
Fs = 250;% �w�] Fs = 250Hz

%% FIR LPF 30Hz
lpFilt = designfilt('lowpassfir','FilterOrder',15, ...
    'CutoffFrequency',30,'Samplerate',Fs);%original
% lpFilt = designfilt('lowpassfir','FilterOrder',30, ...
%     'CutoffFrequency',30,'Samplerate',Fs);
% fvtool(lpFilt)
%% FIR LPF 100Hz (EMG) 
%*20210805added
lpFilt_EMG = designfilt('lowpassfir','FilterOrder',15, ...
 'CutoffFrequency',100,'Samplerate',250);  

%% IIR HPF 0.5Hz (EEG,EOG)
%  hpFilt = designfilt('highpassfir', ...
%     'FilterOrder',250, ...
%     'PassbandFrequency',0.5, ...
%     'StopbandFrequency',1,...
%     'SampleRate',Fs);%original

%  hpFilt = designfilt('highpassfir', ...
%     'FilterOrder',125, ...
%     'CutoffFrequency',0.5,...    
%     'SampleRate',Fs);

%fvtool(hpFilt)

hpFilt = designfilt('highpassiir', ...
    'FilterOrder',2, ...
    'HalfPowerFrequency',0.5, ...
    'DesignMethod','butter', ...
    'SampleRate',Fs);

 %% IIR HPF 5Hz (EMG)
 %*20210805added
 hpFilt_EMG = designfilt('highpassiir', ...
         'FilterOrder',2, ...
         'HalfPowerFrequency',5, ...
         'DesignMethod','butter', ...
         'SampleRate',Fs);
 %% notch_EMG
 %*20210805added
 notch_EMG = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',Fs);

           
%% Filtering
for i=1:length(data(:,1))
    if indx==4
       if i==4 
           data(i,:)=filter(notch_EMG,data(i,:));
           data(i,:)=filter(lpFilt_EMG,data(i,:));
           data(i,:)=filter(hpFilt_EMG,data(i,:));
       else
           data(i,:)=filter(lpFilt, data(i,:));
           data(i,:)=filter(hpFilt, data(i,:));
       end
    else 
       data(i,:)=filter(lpFilt, data(i,:));
       data(i,:)=filter(hpFilt, data(i,:));
    end
   data(i,:)=data(i,:)*1e6;
end

%% Rescale 1e6 (uV unit)
if(exist('accdata')==1)
    save([fpath '\' fname(1:end-4) '_bleEXGdata.mat'],'data');
    save([fpath '\' fname(1:end-4) '_bleACCdata.mat'],'accdata');
else
        save([fpath '\' fname(1:end-4) '_bleEXGdata.mat'],'data');
end


%% missing data checking
clc;
format long
packageSize = 4;
count = 0;

countData = CH1(4,:)';

diffData = diff(countData);
diffData = diffData - 1;
lossLength=[];
for i = 1:length(diffData)
    if diffData(i) < 0
        diffData(i) = diffData(i) + Fs;
    else
        if diffData(i) > 0
            count = count + 1;
            lossLength(count) = diffData(i);
            intervalPoint(count) = i;
        end
    end
end
if ~isempty(lossLength)
    lossLength = lossLength / packageSize; % 1 package = 4 point
    diffData = diffData / packageSize;
    intervalTime = diff(intervalPoint);
    
    
    intervalTime = intervalTime / Fs ; % uint s
    bins = 0:1:max(intervalTime);
    bin = 1:1:max(lossLength);
    [countsHist,centersHist] = hist(intervalTime,bins);
    
    
    loseTime = sum(diffData) * 0.004 * packageSize;
    realTime = (length(diffData)+1) * 0.004 + loseTime;
    meanValue = mean(intervalTime);
    stdTime = std(intervalTime);
    
    x = [0 max(centersHist)];
    y = [meanValue meanValue];
    
    %% File write
    [countsHistloss,centersHistloss] = hist(lossLength,bin);
    
    fid=fopen([fpath '\' fname(1:end-4) '_MissingDataReport.txt'],'w');
    fprintf(fid,'��ڶq���ɶ�:%.3fs\n',realTime);
    fprintf(fid,'�򥢮ɶ�:%.3fs\n',loseTime);
    fprintf(fid,'�������T�v:%f%%\n',(realTime-loseTime)/realTime*100);
    fprintf(fid,'�������I����ɶ�:%.2fs\n',meanValue);
    fprintf(fid,'�������I����ɶ��зǮt:%.2fs\n\n',stdTime);
    fprintf(fid,'�������I�̪�����ɶ�:%.2fs\n', max(intervalTime));
    fprintf(fid,'�������I�̵u����ɶ�:%.2fs\n\n', min(intervalTime));
    
    lossTotalPack = 0;
    sumLoss6 = 0;
    for i = 1:length(centersHistloss)
        lossTotalPack = lossTotalPack + i*countsHistloss(i);
        if i > 5
            sumLoss6 = sumLoss6 + i*countsHistloss(i);
        end
    end
    
    fprintf(fid,'�`�ʥ]��:%9.0f\n',realTime/0.004/4);
    fprintf(fid,'�򥢫ʥ]��:%d\n\n',lossTotalPack);
    
    for i = 1:length(centersHistloss)
        if i < 6
            fprintf(fid,'�s��򥢫ʥ] %d :%d\t%3.1f%%\n',i,countsHistloss(i), (countsHistloss(i)*i)/lossTotalPack*100);
        else
            break;
        end
    end
    
    fprintf(fid,'�s��򥢫ʥ] >5 :\t%3.1f%%\n',sumLoss6 / lossTotalPack * 100);
    
    fclose(fid);  %�����ɮ�
    %type MissingDataReport.txt  %�N�s�ɤ��e�L�X
    
    %%
    figure('Position',get(0,'screensize'));
    %% plot
    figure(1)
    subplot(2,1,1)
    plot((1:length(diffData))/Fs,diffData)
    axis tight;
    title('�򥢫ʥ]������')
    xlabel('�����ɶ�(s)')
    ylabel('�򥢫ʥ]��')
    
    subplot(2,1,2)
    hist(lossLength,bin)
    axis([0.5, inf, -inf, inf]);
    title('�s��򥢫ʥ]�έp')
    xlabel('�s��򥢫ʥ]��')
    ylabel('����')
    h = getframe(1);
    imwrite(h.cdata,[fpath '\' fname(1:end-4) '_�򥢫ʥ].jpg']);
    
    figure('Position',get(0,'screensize'));
    figure(2)
    subplot(2,1,1)
    bar(centersHist, countsHist)
    hold on;
    % plot(x,y, 'r')
    % legend('Lost interval time','Average lost');
    % text(max(centersHist), meanValue, num2str(meanValue), 'HorizontalAlignment', 'right');
    axis([-0.5, inf, -inf, inf]);
    set(gca, 'xtick', 0:5:max(centersHist))
    title('�ʥ]�򥢶��j��������')
    xlabel('�򥢫ʥ]�ɶ����Z (s)')
    ylabel('����')
    hold off;
    
    subplot(2,1,2)
    bar(centersHist, countsHist/sum(countsHist)*100)
    axis([-0.5, inf, -inf, inf]);
    set(gca, 'xtick', 0:5:max(centersHist))
    title('�ʥ]�򥢶��j�����ʤ���')
    xlabel('�򥢫ʥ]�ɶ����Z (s)')
    ylabel('�򥢦ʤ��� (%)')
    w = getframe(2);
    imwrite(w.cdata,[fpath '\' fname(1:end-4) '_�򥢫ʥ]����.jpg']);
end
end

