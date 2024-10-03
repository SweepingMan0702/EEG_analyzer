function [CH1_output, CH2_output, CH3_output, CH4_output] = data232_transformers_4_channel( start, packsize, gain, tailpacksize,endpacksize)
%% 4channel 無加速度
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%測試維修版本
%目標優化DEC2HEX部份
%for 平行處理

%----------3_5版---------------------------------------------------
% 在72行處多加判斷式判斷239、222，避免出現資料中173''''190狀況誤判。
% 增加預設 packsize為36, gain為24
%------------------------------------------------------------------
%----------3_6版---------------------------------------------------
% 在121,122更換資料轉換函數，使轉換時間為3_4、3_5版的 2.6倍
% dec2hex、hex2dec 非常浪費資源
%------------------------------------------------------------------

%----------3_7版---------------------------------------------------
% 修改正負轉換公式，避免可能的位移偏差，已經與SD卡資料校正
%
%------------------------------------------------------------------


%----------3_8版---------------------------------------------------
% 增加預設 packsize為152
%藍芽格式更改
%------------------------------------------------------------------


%----------3_9版---------------------------------------------------
% 增加預設 packsize為152
%藍芽格式更改
%------------------------------------------------------------------


%----------4_1版---------------------------------------------------
% 增加預設 packsize為232
%藍芽格式更改
%------------------------------------------------------------------



%% BLE Transmission Data Format
%
% 'Time' is counter numbers
% Total byte: 232 byte

%----------------------------------------------------------------------------------------------------------------
% (     START    )|(    channel 1   )|(    channel 1   )|(    channel 1   )|(    channel 1   )|-> -> -> -> -> ->|
%-----------------|------------------|------------------|------------------|------------------|-----------------|
%                 |                  |                  |                  |                  |                 |
% [173][222][0][0]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|                 |
%                 |                  |                  |                  |                  |                 |
%----------------------------------------------------------------------------------------------------------------
%-> -> -> -> -> ->|(    channel 2   )|(    channel 2   )|(    channel 2   )|(    channel 2   )|(      END     ) |
%-----------------|------------------|------------------|------------------|------------------|-----------------|
%                 |                  |                  |                  |                  |                 |
%                 |[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[239][190][0][0] |
%                 |                  |                  |                  |                  |                 |
%---------------------------------------------------------------------------------------------------------------|

if nargin<1,error('at least 1 input arguments required'), end
if nargin<2  packsize = 232 ;end % 預設 packsize為232
if nargin<3  gain = 24; end     % 預設 gain為24
if nargin<4  tailpacksize=4; end% 預設檔封包的大小endpacksize為4
if nargin<5  endpacksize=4; end% 預設檔尾封包的大小endpacksize為4

everychannelpoint=(packsize-tailpacksize-endpacksize)/4/4;%每一封包的點數




%% 找出第一筆檔頭 173
    temp_start = find(start == 173);% 找出所有開頭start flag 173 位置(x)
    
    % 如果 173到下個173為packsize(36)與173下個byte為222
    % 則 將data開始標記暫存起來(head)
    for i = 1:length(temp_start)-1
        if ((temp_start(i+1)-temp_start(i) == packsize) &&  start(temp_start(i)+1) == 222)
            head = temp_start(i);% 跳出for迴圈
            break;
        end
    end

    % 如果head變量不存在(沒有值)，則跳出此函數。
    if ~exist('head','var')
        
        CH1_output = 0;
        CH2_output = 0;
        CH3_output = 0;
        CH4_output = 0;
        return;% 跳出此函數
    end
    
%% 找最後一筆檔尾 190
    temp_tail = find(start == 190);% 找出所有結尾 end flag 190 位置(x)
    temp_tail = sort(temp_tail,'descend');% 倒排序

    for i = 1:length(temp_tail)-1
        if (temp_tail(i)-temp_tail(i+1) == packsize &&  start(temp_tail(i)-1) == 239)
            tail = temp_tail(i);
            break;% 跳出for迴圈
        end
    end
    
    % 如果tail變量不存在(沒有值)，則跳出此函數。
    if ~exist('tail','var')
        CH1_output = 0;
        CH2_output = 0;
        CH3_output = 0;
        CH4_output = 0;
    return;% 跳出此函數
    end

%% 資料解譯

    % data資料取自第一個檔頭位置(head),最後一個檔尾位置(tail)
    data = start(head:tail);
    % 找出所有開頭start flag 173 位置(x)
    start_ini = find(data == 173);
    CH1 = [];
    CH2 = [];
    CH3 = [];
    CH4 = [];
    % 取封包長度(173開頭為一包)
    for i=1:length(start_ini)   
        % 如果start_ini(i)未超出資料範圍(data)
        if( (start_ini(i)+packsize-endpacksize-1) < length(data))
            % 如果檔頭檔尾正確(173'''''190)
            if( (data(start_ini(i)+packsize-endpacksize+1) == 190) & (data(start_ini(i)+packsize-endpacksize) == 239) & (data(start_ini(i)+1) == 222) )
                ini = start_ini(i);
                % 重新排列封包中5:60，共14個資料點
                tempCH1 = reshape( data( (ini+tailpacksize):(ini+tailpacksize+(packsize-endpacksize-tailpacksize)/4)-1 ), [], everychannelpoint );
                % 重新排列封包中61:116，共14個資料點
                tempCH2 = reshape( data( ini+tailpacksize+(packsize-endpacksize-tailpacksize)/4 :ini+tailpacksize+(packsize-endpacksize-tailpacksize)/2-1 ), [], everychannelpoint );
                % 重新排列封包中117:172，共14個資料點
                tempCH3 = reshape( data( (ini+tailpacksize+(packsize-endpacksize-tailpacksize)/2):(ini+tailpacksize+(packsize-endpacksize-tailpacksize)*3/4)-1 ), [], everychannelpoint );
                % 重新排列封包中173:228，共14個資料點
                tempCH4 = reshape( data( ini+tailpacksize+(packsize-endpacksize-tailpacksize)*3/4 :ini+tailpacksize+(packsize-endpacksize-tailpacksize)-1 ), [], everychannelpoint );

                CH1 = [CH1 tempCH1];
                CH2 = [CH2 tempCH2];
                CH3 = [CH3 tempCH3];
                CH4 = [CH4 tempCH4];
            end
         end
     end
% 
% 創建為0的一維矩陣
data2_CH1 = zeros(1,size(CH1,2));
data2_CH2 = zeros(1,size(CH1,2));
data2_CH3 = zeros(1,size(CH1,2));
data2_CH4 = zeros(1,size(CH1,2));

reverse = 16^6;
% 將 [LB][MB][HB] 合併為24bit(3byte)
for i = 1:size(CH1,2)
    %*** 3_4、3_5版轉換程式*****************************************************************************************************
    %         data2_CH1(i) = hex2dec(  [dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]  );
    %         data2_CH2(i) = hex2dec(  [dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]  );
    %***************************************************************************************************************************
    %3_6版轉換程式****************************************************************************************************************************************************************
    %測試         data2_CH1(i) = typecast(uint32(sscanf( ([dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]), '%x')), 'int32');
    %測試         data2_CH2(i) = typecast(uint32(sscanf( ([dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]), '%x')), 'int32');
%     data2_CH1(i) = typecast(uint32(sscanf( ([ sprintf('%02X',CH1(3,i)) sprintf('%02X' , CH1(2,i)) sprintf('%02X' , CH1(1,i))]), '%x')), 'int32');
%     data2_CH2(i) = typecast(uint32(sscanf( ([ sprintf('%02X',CH2(3,i)) sprintf('%02X' , CH2(2,i)) sprintf('%02X' , CH2(1,i))]), '%x')), 'int32');
    %*****************************************************************************************************************************************************************************
    
    data2_CH1(i) = CH1(3,i)*16*16*16*16+CH1(2,i)*16*16+CH1(1,i);
    if data2_CH1(i)>=1e7
        data2_CH1(i) = data2_CH1(i)-reverse;
    end
    data2_CH2(i) = CH2(3,i)*16*16*16*16+CH2(2,i)*16*16+CH2(1,i);
    if data2_CH2(i)>=1e7
        data2_CH2(i) = data2_CH2(i)-reverse;
    end
     data2_CH3(i) = CH3(3,i)*16*16*16*16+CH3(2,i)*16*16+CH3(1,i);
    if data2_CH3(i)>=1e7
        data2_CH3(i) = data2_CH3(i)-reverse;
    end
    data2_CH4(i) = CH4(3,i)*16*16*16*16+CH4(2,i)*16*16+CH4(1,i);
    if data2_CH4(i)>=1e7
        data2_CH4(i) = data2_CH4(i)-reverse;
    end
    
end

% 
% flag = find(data2_CH1 >= 1e7);
% for i = 1:length(flag)
%     data2_CH1(flag(i)) = data2_CH1(flag(i))-reverse;
% end
% 
% flag = find(data2_CH2 >= 1e7);
% for i = 1:length(flag)
%     data2_CH2(flag(i)) = data2_CH2(flag(i))-reverse;
% end


% 轉換成原始電壓( Ref.datasheet REV_C  Page 38 )
%     CH1_output = (data2_CH1);
%     CH2_output = (data2_CH2);
    CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
    CH2_output = (data2_CH2)*(4.5) /gain / (2^23);
    CH3_output = (data2_CH3)*(4.5) /gain / (2^23);
    CH4_output = (data2_CH4)*(4.5) /gain / (2^23);
end
