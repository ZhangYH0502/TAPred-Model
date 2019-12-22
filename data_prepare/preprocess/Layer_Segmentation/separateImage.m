function matrixOut=separateImage(delta_l,image)
%%%% ������:separateImage
%% ��������:��ԭͼ�������Ӧ�Ĳ������ָ�ɶ�Ӧ����ͼ��
%% �ָ��Ч����Ϊ����������Ҫ�����򣬽��Ϳռ临�Ӷ�
%% ����˵��:
%% image      ---ͼ��Դ���ݣ���3Dͼ��
%% delta_l    ---������֮����С���������, ��delta_u�����ֵһһ��Ӧ
%% ����ʱ��֤delta_l����Ϊ��


[height,width,slice]=size(image);
sum_delta_l=sum(delta_l);       %%�����delta_l����ֵ�ĺ�
up=0;                           %%��ʼ����ͼ������·�Χ
down=sum_delta_l;               %%��ʼ����ͼ������·�Χ
matrixOut=cell(1,size(delta_l,2)+1);
for count=1:size(delta_l,2)+1
    matrixOut{count}=image(down+1:height-up,:,:);
    if(count==size(delta_l,2)+1)
        break;
    end
    down=down-delta_l(count);
    up=up+delta_l(count);
end
return