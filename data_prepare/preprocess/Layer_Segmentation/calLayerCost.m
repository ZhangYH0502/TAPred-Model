function [I_costOut] = calLayerCost(I_in,delta_l,methods)
%% ��������Ȩ��
%% I_in --- ��ʾ����ͼ��
%% delta_l --- ��ʾ�������
%% methods --- ��ʾ������Ŀǰ�����û���edge����
[height,width,slice] = size(I_in);
numOfSurf = size(delta_l,2) + 1;
if size(methods,2) ~= numOfSurf     %��Ҫ�ָ�ı�������Ҫ��methods��ѡ��һһ��Ӧ
    error('unmatch methods number and surface Number!');
end

I_in_mat = separateImage(delta_l,I_in);    %�ָ�ͼ��
for i = 1:numOfSurf
   if strcmp(methods{i},'edge')            % ��ʾ���û��ڱ�Ե��Ȩ��
       I_costOut{i} = edge_Cost(I_in_mat{i});     %���û��ڱ�Ե������Ŀǰ���û������Ĳ�ֵ�
   end
   if  strcmp(methods{i},'ori')
       I_costOut{i} = Ori_Cost(I_in_mat{i});
   end
   if  strcmp(methods{i},'edge1')
       I_costOut{i} = edge_Cost1(I_in_mat{i});
   end
end
return