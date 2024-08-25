function [CH1_output, CH2_output,CH1,CH2,dataX,dataY,dataZ] = data144_transformers4_1( start, packsize, gain, tailpacksize,endpacksize)
%[CH1_output, CH2_output, CH1, CH2,X,Y,Z,dataX,dataY,dataZ] = data144_transformers4_1( start, packsize, gain, tailpacksize,endpacksize)
%%2 channel ���[�t�׭p



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
if nargin<2  packsize = 144 ;end % �w�] packsize��144
if nargin<3  gain = 24; end     % �w�] gain��24
if nargin<4  tailpacksize=20; end% �w�]�ɫʥ]���j�pendpacksize��17
if nargin<5  endpacksize=4; end% �w�]�ɧ��ʥ]���j�pendpacksize��4

% everypackpoint=(packsize-tailpacksize-endpacksize)/4/2;%�C�@�ʥ]���I��
everypackpoint=15;



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
    return;% ���X�����
end

%% ��Ƹ�Ķ

% data��ƨ��۲Ĥ@�����Y��m(head),�̫�@���ɧ���m(tail)
data = start(head:tail);
% ��X�Ҧ��}�Ystart flag 173 ��m(x)
start_ini = find(data == 173);
CH1 = [];
CH2 = [];
X = [];
Y = [];
Z = [];
% ���ʥ]����(173�}�Y���@�])
for i=1:length(start_ini)
    % �p�Gstart_ini(i)���W�X��ƽd��(data)
    if( (start_ini(i)+packsize-endpacksize-1) < length(data))
        % �p�G���Y�ɧ����T(173'''''190)
        if( (data(start_ini(i)+packsize-endpacksize+1) == 190) & (data(start_ini(i)+packsize-endpacksize) == 239) & (data(start_ini(i)+1) == 222) )
            ini = start_ini(i);
            tempX=reshape( data(ini+2:ini+7), [], 3 );
            tempY= reshape(data(ini+8:ini+13), [], 3 );
            tempZ= reshape(data(ini+14:ini+19), [], 3 );
            % ���s�ƦC�ʥ]��21:80�A�@15�Ӹ���I
            tempCH1 = reshape( data(ini+20:ini+79), [], everypackpoint );
            % ���s�ƦC�ʥ]��81:140�A�@15�Ӹ���I
            tempCH2 = reshape( data(ini+80:ini+139), [], everypackpoint );
            X = [X tempX];
            Y = [Y tempY];
            Z = [Z tempZ];
            CH1 = [CH1 tempCH1];
            CH2 = [CH2 tempCH2];
        end
    end
end
%
% �Ыج�0���@���x�}
data2_CH1 = zeros(1,size(CH1,2));
data2_CH2 = zeros(1,size(CH1,2));
dataX = zeros(1,size(X,2));
dataY= zeros(1,size(X,2));
dataZ = zeros(1,size(X,2));


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
    
    data2_CH1(i) = CH1(3,i)*16*16*16*16+CH1(2,i)*16*16+CH1(1,i);
    if data2_CH1(i)>=1e7
        data2_CH1(i) = data2_CH1(i)-reverse;
    end
    data2_CH2(i) = CH2(3,i)*16*16*16*16+CH2(2,i)*16*16+CH2(1,i);
    if data2_CH2(i)>=1e7
        data2_CH2(i) = data2_CH2(i)-reverse;
    end
    
    
    
    %   dataX(i) = typecast(uint32(sscanf( ([ sprintf('%02X',X(2,i)) sprintf('%02X' , X(1,i))]), '%x')), 'int32');
    %*****************************************************************************************************************************************************************************
end
reverse2=2^12;
for i = 1:size(X,2)
    dataX(i)=(mod(X(2,i),16))*256+ X(1,i);
    if dataX(i)>=2048
        dataX(i)=dataX(i)-reverse2;
    end
    dataY(i)=(mod(Y(2,i),16))*256+ Y(1,i);
    if dataY(i)>=2048
        dataY(i)=dataY(i)-reverse2;
    end
    dataZ(i)=(mod(Z(2,i),16))*256+ Z(1,i);
    if dataZ(i)>=2048
        dataZ(i)=dataZ(i)-reverse2;
    end
%     
%     TEMP=[dec2hex(X(2,i),2) dec2hex(X(1,i),2)];
%     dataX(i) = hex2dec( TEMP(2:4)   );
%     TEMP=[dec2hex(Y(2,i),2) dec2hex(Y(1,i),2)];
%     dataY(i) = hex2dec( TEMP(2:4)   );
%     TEMP=[dec2hex(Z(2,i),2) dec2hex(Z(1,i),2)];
%     dataZ(i) = hex2dec( TEMP(2:4)   );
%     
end



CH1_output = (data2_CH1)*(4.5) /gain / (2^23);
CH2_output = (data2_CH2)*(4.5) /gain / (2^23);

end
