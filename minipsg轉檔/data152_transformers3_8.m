function [CH1_output, CH2_output, CH1, CH2] = data152_transformers3_8( start, packsize, gain)
% data=load('');
% [CH1_output, CH2_output, CH1, CH2] = data152_transformers3_8(data);

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



%% BLE Transmission Data Format
%
% 'Time' is counter numbers
% Total byte: 148 byte
%---------------------------------------------------------------------------------------------------
% (  START )|(    channel 1   )|(    channel 1   )|(    channel 1   )|(    channel 1   )|-> -> -> ->|
%-----------|------------------|------------------|------------------|------------------|-----------|
%           |                  |                  |                  |                  |           |
% [173][222]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|           |
%           |                  |                  |                  |                  |           |
%---------------------------------------------------------------------------------------------------
%-> -> -> ->|(    channel 2   )|(    channel 2   )|(    channel 2   )|(    channel 2   )|(   END  ) |
%-----------|------------------|------------------|------------------|------------------|-----------|
%           |                  |                  |                  |                  |           |
%           |[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[LB][MB][HB][Time]|[239][190] |
%           |                  |                  |                  |                  |           |
%---------------------------------------------------------------------------------------------------|

if nargin<1,error('at least 1 input arguments required'), end
if nargin<2  packsize = 150 ;end % 預設 packsize為148
if nargin<3  gain = 24; end     % 預設 gain為24

%% 找出第一筆檔頭 173
    temp_start = find(start == 173);% 找出所有開頭start flag 173 位置(x)
    
    % 如果 173到下個173為packsize(36)與173下個byte為222
    % 則 將data開始標記暫存起來(head)
    for i = 1:length(temp_start)-1
        if ((temp_start(i+1)-temp_start(i) == 152) &&  start(temp_start(i)+1) == 222)
            head = temp_start(i);% 跳出for迴圈
            break;
        end
    end

    % 如果head變量不存在(沒有值)，則跳出此函數。
    if ~exist('head','var')
        
        CH1_output = 0;
        CH2_output = 0;
        return;% 跳出此函數
    end
    
%% 找最後一筆檔尾 190
    temp_tail = find(start == 190);% 找出所有結尾 end flag 190 位置(x)
    temp_tail = sort(temp_tail,'descend');% 倒排序

    for i = 1:length(temp_tail)-1
        if (temp_tail(i)-temp_tail(i+1) == 152 &&  start(temp_tail(i)-1) == 239)
            tail = temp_tail(i);
            break;% 跳出for迴圈
        end
    end
    
    % 如果tail變量不存在(沒有值)，則跳出此函數。
    if ~exist('tail','var')
        CH1_output = 0;
        CH2_output = 0;
    return;% 跳出此函數
    end

%% 資料解譯
    tic
    % data資料取自第一個檔頭位置(head),最後一個檔尾位置(tail)
    data = start(head:tail);
    % 找出所有開頭start flag 173 位置(x)
    start_ini = find(data == 173);
    CH1 = [];
    CH2 = [];
    % 取封包長度(173開頭為一包)
    for i=1:length(start_ini)   
        % 如果start_ini(i)未超出資料範圍(data)
        if( (start_ini(i)+147) < length(data))
            % 如果檔頭檔尾正確(173'''''190)
            if( (data(start_ini(i)+147+2) == 190) & (data(start_ini(i)+146+2) == 239) & (data(start_ini(i)+1) == 222) )
                ini = start_ini(i);
                % 重新排列封包中3:76，共18個資料點
                tempCH1 = reshape( data( (ini+4):(ini+2+2 + ( (packsize-4)/2 ) -2) ), [], 18 );
                % 重新排列封包中76:146，共四個資料點
                tempCH2 = reshape( data( (ini+74+2):(ini+74+2+ ( (packsize-4)/2 )-2) ), [], 18 );

                CH1 = [CH1 tempCH1];
                CH2 = [CH2 tempCH2];
            end
         end
    end
   toc
% 
% 創建為0的一維矩陣
data2_CH1 = zeros(1,size(CH1,2));
data2_CH2 = zeros(1,size(CH1,2));
reverse = 16^6;
% 將 [LB][MB][HB] 合併為24bit(3byte)
tic
for i = 1:size(CH1,2) 
%*** 3_4、3_5版轉換程式*****************************************************************************************************
%         data2_CH1(i) = hex2dec(  [dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]  );
%         data2_CH2(i) = hex2dec(  [dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]  );
%***************************************************************************************************************************
%3_6版轉換程式****************************************************************************************************************************************************************
%測試         data2_CH1(i) = typecast(uint32(sscanf( ([dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]), '%x')), 'int32');
%測試         data2_CH2(i) = typecast(uint32(sscanf( ([dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]), '%x')), 'int32');
%         data2_CH1(i) = typecast(uint32(sscanf( ([ sprintf('%02X',CH1(3,i)) sprintf('%02X' , CH1(2,i)) sprintf('%02X' , CH1(1,i))]), '%x')), 'int32');
%         data2_CH2(i) = typecast(uint32(sscanf( ([ sprintf('%02X',CH2(3,i)) sprintf('%02X' , CH2(2,i)) sprintf('%02X' , CH2(1,i))]), '%x')), 'int32');
        
        data2_CH1(i) = CH1(3,i)*16*16*16*16+CH1(2,i)*16*16+CH1(1,i);
        if data2_CH1(i)>=1e7
            data2_CH1(i) = data2_CH1(i)-reverse;
        end
        data2_CH2(i) = CH2(3,i)*16*16*16*16+CH2(2,i)*16*16+CH2(1,i);
         if data2_CH2(i)>=1e7
            data2_CH2(i) = data2_CH2(i)-reverse;
        end
        
        
%*****************************************************************************************************************************************************************************
end

toc



% 轉換成原始電壓( Ref.datasheet REV_C  Page 38 )
%     CH1_output = (data2_CH1);
%     CH2_output = (data2_CH2);
    CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
    CH2_output = (data2_CH2)*(4.5) /gain / (2^23);
    
%% DATA_Saving
% save('CH1_output.mat','CH1_output');
% save('CH2_output.mat','CH2_output');
end
