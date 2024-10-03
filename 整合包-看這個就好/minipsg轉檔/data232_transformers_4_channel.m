function [CH1_output, CH2_output, CH3_output, CH4_output] = data232_transformers_4_channel( start, packsize, gain, tailpacksize,endpacksize)
%% 4channel �L�[�t��
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%���պ��ת���
%�ؼ��u��DEC2HEX����
%for ����B�z

%----------3_5��---------------------------------------------------
% �b72��B�h�[�P�_���P�_239�B222�A�קK�X�{��Ƥ�173''''190���p�~�P�C
% �W�[�w�] packsize��36, gain��24
%------------------------------------------------------------------
%----------3_6��---------------------------------------------------
% �b121,122�󴫸���ഫ��ơA���ഫ�ɶ���3_4�B3_5���� 2.6��
% dec2hex�Bhex2dec �D�`���O�귽
%------------------------------------------------------------------

%----------3_7��---------------------------------------------------
% �ק勵�t�ഫ�����A�קK�i�઺�첾���t�A�w�g�PSD�d��Ʈե�
%
%------------------------------------------------------------------


%----------3_8��---------------------------------------------------
% �W�[�w�] packsize��152
%�Ūޮ榡���
%------------------------------------------------------------------


%----------3_9��---------------------------------------------------
% �W�[�w�] packsize��152
%�Ūޮ榡���
%------------------------------------------------------------------


%----------4_1��---------------------------------------------------
% �W�[�w�] packsize��232
%�Ūޮ榡���
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
if nargin<2  packsize = 232 ;end % �w�] packsize��232
if nargin<3  gain = 24; end     % �w�] gain��24
if nargin<4  tailpacksize=4; end% �w�]�ɫʥ]���j�pendpacksize��4
if nargin<5  endpacksize=4; end% �w�]�ɧ��ʥ]���j�pendpacksize��4

everychannelpoint=(packsize-tailpacksize-endpacksize)/4/4;%�C�@�ʥ]���I��




%% ��X�Ĥ@�����Y 173
    temp_start = find(start == 173);% ��X�Ҧ��}�Ystart flag 173 ��m(x)
    
    % �p�G 173��U��173��packsize(36)�P173�U��byte��222
    % �h �Ndata�}�l�аO�Ȧs�_��(head)
    for i = 1:length(temp_start)-1
        if ((temp_start(i+1)-temp_start(i) == packsize) &&  start(temp_start(i)+1) == 222)
            head = temp_start(i);% ���Xfor�j��
            break;
        end
    end

    % �p�Ghead�ܶq���s�b(�S����)�A�h���X����ơC
    if ~exist('head','var')
        
        CH1_output = 0;
        CH2_output = 0;
        CH3_output = 0;
        CH4_output = 0;
        return;% ���X�����
    end
    
%% ��̫�@���ɧ� 190
    temp_tail = find(start == 190);% ��X�Ҧ����� end flag 190 ��m(x)
    temp_tail = sort(temp_tail,'descend');% �˱Ƨ�

    for i = 1:length(temp_tail)-1
        if (temp_tail(i)-temp_tail(i+1) == packsize &&  start(temp_tail(i)-1) == 239)
            tail = temp_tail(i);
            break;% ���Xfor�j��
        end
    end
    
    % �p�Gtail�ܶq���s�b(�S����)�A�h���X����ơC
    if ~exist('tail','var')
        CH1_output = 0;
        CH2_output = 0;
        CH3_output = 0;
        CH4_output = 0;
    return;% ���X�����
    end

%% ��Ƹ�Ķ

    % data��ƨ��۲Ĥ@�����Y��m(head),�̫�@���ɧ���m(tail)
    data = start(head:tail);
    % ��X�Ҧ��}�Ystart flag 173 ��m(x)
    start_ini = find(data == 173);
    CH1 = [];
    CH2 = [];
    CH3 = [];
    CH4 = [];
    % ���ʥ]����(173�}�Y���@�])
    for i=1:length(start_ini)   
        % �p�Gstart_ini(i)���W�X��ƽd��(data)
        if( (start_ini(i)+packsize-endpacksize-1) < length(data))
            % �p�G���Y�ɧ����T(173'''''190)
            if( (data(start_ini(i)+packsize-endpacksize+1) == 190) & (data(start_ini(i)+packsize-endpacksize) == 239) & (data(start_ini(i)+1) == 222) )
                ini = start_ini(i);
                % ���s�ƦC�ʥ]��5:60�A�@14�Ӹ���I
                tempCH1 = reshape( data( (ini+tailpacksize):(ini+tailpacksize+(packsize-endpacksize-tailpacksize)/4)-1 ), [], everychannelpoint );
                % ���s�ƦC�ʥ]��61:116�A�@14�Ӹ���I
                tempCH2 = reshape( data( ini+tailpacksize+(packsize-endpacksize-tailpacksize)/4 :ini+tailpacksize+(packsize-endpacksize-tailpacksize)/2-1 ), [], everychannelpoint );
                % ���s�ƦC�ʥ]��117:172�A�@14�Ӹ���I
                tempCH3 = reshape( data( (ini+tailpacksize+(packsize-endpacksize-tailpacksize)/2):(ini+tailpacksize+(packsize-endpacksize-tailpacksize)*3/4)-1 ), [], everychannelpoint );
                % ���s�ƦC�ʥ]��173:228�A�@14�Ӹ���I
                tempCH4 = reshape( data( ini+tailpacksize+(packsize-endpacksize-tailpacksize)*3/4 :ini+tailpacksize+(packsize-endpacksize-tailpacksize)-1 ), [], everychannelpoint );

                CH1 = [CH1 tempCH1];
                CH2 = [CH2 tempCH2];
                CH3 = [CH3 tempCH3];
                CH4 = [CH4 tempCH4];
            end
         end
     end
% 
% �Ыج�0���@���x�}
data2_CH1 = zeros(1,size(CH1,2));
data2_CH2 = zeros(1,size(CH1,2));
data2_CH3 = zeros(1,size(CH1,2));
data2_CH4 = zeros(1,size(CH1,2));

reverse = 16^6;
% �N [LB][MB][HB] �X�֬�24bit(3byte)
for i = 1:size(CH1,2)
    %*** 3_4�B3_5���ഫ�{��*****************************************************************************************************
    %         data2_CH1(i) = hex2dec(  [dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]  );
    %         data2_CH2(i) = hex2dec(  [dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]  );
    %***************************************************************************************************************************
    %3_6���ഫ�{��****************************************************************************************************************************************************************
    %����         data2_CH1(i) = typecast(uint32(sscanf( ([dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]), '%x')), 'int32');
    %����         data2_CH2(i) = typecast(uint32(sscanf( ([dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]), '%x')), 'int32');
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


% �ഫ����l�q��( Ref.datasheet REV_C  Page 38 )
%     CH1_output = (data2_CH1);
%     CH2_output = (data2_CH2);
    CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
    CH2_output = (data2_CH2)*(4.5) /gain / (2^23);
    CH3_output = (data2_CH3)*(4.5) /gain / (2^23);
    CH4_output = (data2_CH4)*(4.5) /gain / (2^23);
end
