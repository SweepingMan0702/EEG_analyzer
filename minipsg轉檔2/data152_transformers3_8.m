function [CH1_output, CH2_output, CH1, CH2] = data152_transformers3_8( start, packsize, gain)
% data=load('');
% [CH1_output, CH2_output, CH1, CH2] = data152_transformers3_8(data);

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
if nargin<2  packsize = 150 ;end % �w�] packsize��148
if nargin<3  gain = 24; end     % �w�] gain��24

%% ��X�Ĥ@�����Y 173
    temp_start = find(start == 173);% ��X�Ҧ��}�Ystart flag 173 ��m(x)
    
    % �p�G 173��U��173��packsize(36)�P173�U��byte��222
    % �h �Ndata�}�l�аO�Ȧs�_��(head)
    for i = 1:length(temp_start)-1
        if ((temp_start(i+1)-temp_start(i) == 152) &&  start(temp_start(i)+1) == 222)
            head = temp_start(i);% ���Xfor�j��
            break;
        end
    end

    % �p�Ghead�ܶq���s�b(�S����)�A�h���X����ơC
    if ~exist('head','var')
        
        CH1_output = 0;
        CH2_output = 0;
        return;% ���X�����
    end
    
%% ��̫�@���ɧ� 190
    temp_tail = find(start == 190);% ��X�Ҧ����� end flag 190 ��m(x)
    temp_tail = sort(temp_tail,'descend');% �˱Ƨ�

    for i = 1:length(temp_tail)-1
        if (temp_tail(i)-temp_tail(i+1) == 152 &&  start(temp_tail(i)-1) == 239)
            tail = temp_tail(i);
            break;% ���Xfor�j��
        end
    end
    
    % �p�Gtail�ܶq���s�b(�S����)�A�h���X����ơC
    if ~exist('tail','var')
        CH1_output = 0;
        CH2_output = 0;
    return;% ���X�����
    end

%% ��Ƹ�Ķ
    tic
    % data��ƨ��۲Ĥ@�����Y��m(head),�̫�@���ɧ���m(tail)
    data = start(head:tail);
    % ��X�Ҧ��}�Ystart flag 173 ��m(x)
    start_ini = find(data == 173);
    CH1 = [];
    CH2 = [];
    % ���ʥ]����(173�}�Y���@�])
    for i=1:length(start_ini)   
        % �p�Gstart_ini(i)���W�X��ƽd��(data)
        if( (start_ini(i)+147) < length(data))
            % �p�G���Y�ɧ����T(173'''''190)
            if( (data(start_ini(i)+147+2) == 190) & (data(start_ini(i)+146+2) == 239) & (data(start_ini(i)+1) == 222) )
                ini = start_ini(i);
                % ���s�ƦC�ʥ]��3:76�A�@18�Ӹ���I
                tempCH1 = reshape( data( (ini+4):(ini+2+2 + ( (packsize-4)/2 ) -2) ), [], 18 );
                % ���s�ƦC�ʥ]��76:146�A�@�|�Ӹ���I
                tempCH2 = reshape( data( (ini+74+2):(ini+74+2+ ( (packsize-4)/2 )-2) ), [], 18 );

                CH1 = [CH1 tempCH1];
                CH2 = [CH2 tempCH2];
            end
         end
    end
   toc
% 
% �Ыج�0���@���x�}
data2_CH1 = zeros(1,size(CH1,2));
data2_CH2 = zeros(1,size(CH1,2));
reverse = 16^6;
% �N [LB][MB][HB] �X�֬�24bit(3byte)
tic
for i = 1:size(CH1,2) 
%*** 3_4�B3_5���ഫ�{��*****************************************************************************************************
%         data2_CH1(i) = hex2dec(  [dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]  );
%         data2_CH2(i) = hex2dec(  [dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]  );
%***************************************************************************************************************************
%3_6���ഫ�{��****************************************************************************************************************************************************************
%����         data2_CH1(i) = typecast(uint32(sscanf( ([dec2hex(CH1(5,i),2) dec2hex(CH1(3,i),2) dec2hex(CH1(2,i),2) dec2hex(CH1(1,i),2)]), '%x')), 'int32');
%����         data2_CH2(i) = typecast(uint32(sscanf( ([dec2hex(CH2(5,i),2) dec2hex(CH2(3,i),2) dec2hex(CH2(2,i),2) dec2hex(CH2(1,i),2)]), '%x')), 'int32');
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



% �ഫ����l�q��( Ref.datasheet REV_C  Page 38 )
%     CH1_output = (data2_CH1);
%     CH2_output = (data2_CH2);
    CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
    CH2_output = (data2_CH2)*(4.5) /gain / (2^23);
    
%% DATA_Saving
% save('CH1_output.mat','CH1_output');
% save('CH2_output.mat','CH2_output');
end
