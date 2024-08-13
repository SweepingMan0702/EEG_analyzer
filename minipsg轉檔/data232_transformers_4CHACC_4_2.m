function [ACCX_output,ACCY_output,ACCZ_output,CH1,CH1_output, CH2_output, CH3_output, CH4_output] = data232_transformers_4CHACC_4_2( start, packsize, gain, startpacksize,endpacksize)
%% 4channel ���[�t��
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

%----------4_2��---------------------------------------------------
% �W�[�w�] packsize��232
%�Ūޮ榡���
%   START ACCX    ACCY    ACCZ    CH1      CH2      CH3      CH4      END
%   4byte 3*2byte 3*2byte 3*2byte 13*4byte 13*4byte 13*4byte 13*4byte 4byte
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
if nargin<4  startpacksize = 2; end% �w�]�ɫʥ]���j�pstartpacksize��2
if nargin<5  endpacksize = 4; end% �w�]�ɧ��ʥ]���j�pendpacksize��4

EXG_Point_size = 4; %�C�I4byte
ACC_Point_size = 2; %�C�I2byte

EXG_Startbyte = 20;
%everychannelpoint=(packsize-tailpacksize-endpacksize)/4/4;%�C�@�ʥ]���I��
everyEXGchannelpoint = 13;%�C�@�ʥ]���I��
everyACCchannelpoint = 3;%�C�@�ʥ]���I��



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
    
    ACCX_output = 0;
    ACCY_output = 0;
    ACCZ_output = 0;
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
    ACCX_output = 0;
    ACCY_output = 0;
    ACCZ_output = 0;
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
ACCX = [];
ACCY = [];
ACCZ = [];
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
            
%             % ���s�ƦC�ʥ]��3:8�A�@6�Ӹ���I�AACCX
%             tempACCX = reshape( data( (ini+startpacksize):(ini+startpacksize + everyACCchannelpoint*ACC_Point_size -1)), [], everyACCchannelpoint );
%             % ���s�ƦC�ʥ]��9:14�A�@6�Ӹ���I�AACCY
%             tempACCY = reshape( data( (ini+startpacksize + everyACCchannelpoint*ACC_Point_size ):( (ini + startpacksize + everyACCchannelpoint*ACC_Point_size*2)-1 )), [], everyACCchannelpoint );
%             % ���s�ƦC�ʥ]��15:20�A�@6�Ӹ���I�AACCZ
%             tempACCZ = reshape( data(  (ini + startpacksize + everyACCchannelpoint*ACC_Point_size*2) : ini + EXG_Startbyte -1 ), [], everyACCchannelpoint );
%             % ���s�ƦC�ʥ]��21:72�A�@13�Ӹ���I�ACH1
%             tempCH1 = reshape( data( (ini+EXG_Startbyte):((ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)/4)-1) ), [], everyEXGchannelpoint );
%             % ���s�ƦC�ʥ]��73:124�A�@13�Ӹ���I�ACH2
%             tempCH2 = reshape( data( ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)/4 :ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)/2-1 ), [], everyEXGchannelpoint );
%             % ���s�ƦC�ʥ]��125:176�A�@13�Ӹ���I�ACH3
%             tempCH3 = reshape( data( (ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)/2):(ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)*3/4)-1 ), [], everyEXGchannelpoint );
%             % ���s�ƦC�ʥ]��177:228�A�@13�Ӹ���I�ACH4
%             tempCH4 = reshape( data( ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)*3/4 :ini+EXG_Startbyte+(packsize-endpacksize-EXG_Startbyte)-1 ), [], everyEXGchannelpoint );
            
            % ���s�ƦC�ʥ]��3:8�A�@6�Ӹ���I�AACCX
            tempACCX = reshape( data( ini+2:ini+7), [], everyACCchannelpoint );
            % ���s�ƦC�ʥ]��9:14�A�@6�Ӹ���I�AACCY
            tempACCY = reshape( data( ini+8:ini+13), [], everyACCchannelpoint );
            % ���s�ƦC�ʥ]��15:20�A�@6�Ӹ���I�AACCZ
            tempACCZ = reshape( data( ini+14:ini+19), [], everyACCchannelpoint );
            % ���s�ƦC�ʥ]��21:72�A�@13�Ӹ���I�ACH1
            tempCH1 = reshape( data( ini+20:ini+71), [], everyEXGchannelpoint );
            % ���s�ƦC�ʥ]��73:124�A�@13�Ӹ���I�ACH2
            tempCH2 = reshape( data( ini+72:ini+123), [], everyEXGchannelpoint );
            % ���s�ƦC�ʥ]��125:176�A�@13�Ӹ���I�ACH3
            tempCH3 = reshape( data( ini+124:ini+175), [], everyEXGchannelpoint );
            % ���s�ƦC�ʥ]��177:228�A�@13�Ӹ���I�ACH4
            tempCH4 = reshape( data( ini+176:ini+227), [], everyEXGchannelpoint );

            ACCX = [ACCX tempACCX];
            ACCY = [ACCY tempACCY];
            ACCZ = [ACCZ tempACCZ];
            CH1 = [CH1 tempCH1];
            CH2 = [CH2 tempCH2];
            CH3 = [CH3 tempCH3];
            CH4 = [CH4 tempCH4];
        end
        
    end
end
%
% �Ыج�0���@���x�}
data2_ACCX = zeros(1,size(ACCX,2));
data2_ACCY = zeros(1,size(ACCX,2));
data2_ACCZ = zeros(1,size(ACCX,2));
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

reverse2=2^12;
tic

for i = 1:size(ACCX,2)

        data2_ACCX(i)=(mod(ACCX(2,i),16))*256+ ACCX(1,i);
        if data2_ACCX(i)>=2048
            data2_ACCX(i)=data2_ACCX(i)-reverse2;
        end
        data2_ACCY(i)=(mod(ACCY(2,i),16))*256+ ACCY(1,i);
        if data2_ACCY(i)>=2048
            data2_ACCY(i)=data2_ACCY(i)-reverse2;
        end
        data2_ACCZ(i)=(mod(ACCZ(2,i),16))*256+ ACCZ(1,i);
        if data2_ACCZ(i)>=2048
            data2_ACCZ(i)=data2_ACCZ(i)-reverse2;
        end
    
end
toc

%% POP�� XYZ�P�ɬ�0
for(i=1:length(data2_ACCX))
    ckdata2(i) = sqrt( data2_ACCX(i)^2 + data2_ACCY(i)^2 + data2_ACCZ(i)^2 );
end
data3_ACCX = data2_ACCX(ckdata2~=0);
data3_ACCY = data2_ACCY(ckdata2~=0);
data3_ACCZ = data2_ACCZ(ckdata2~=0);


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
ACCX_output = data3_ACCX;
ACCY_output = data3_ACCY;
ACCZ_output = data3_ACCZ;
CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
CH2_output = (data2_CH2)*(4.5) /gain / (2^23);
CH3_output = (data2_CH3)*(4.5) /gain / (2^23);
CH4_output = (data2_CH4)*(4.5) /gain / (2^23);
end
