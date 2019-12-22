function result = MultiGraphCut1(costImages,delta_l,delta_u,delta_x,delta_y)
%%%%������:MultiGraphCut
%%��������:ͼ�������,����cost function���㣬��ͼ�Լ��������С��ļ���
%%����˵��:
%% costImages    ---�ָ�֮���Ȩֵ��ͼ��
%% delta_l         ---�����С��������(�ɱ�ģ�͸ĳ�cell����)
%% delta_u         ---������������飨�ɱ�ģ�͸ĳ�cell���ͣ�
%% delta_x         ---�м�����x
%% delta_y         ---�м�����y
%% result          ---ͼ��������к����������ĵ�Ľ��

surfaceNum = size(costImages,2);    %%�����ͼ�񣬼���Ҫ�ָ�ı�����Ŀ
if surfaceNum ~= size(delta_x,2) || surfaceNum ~= size(delta_y,2)
    error('the surfaceNum and the size of delta_x or delta_y is not matched!');
end
costVector=cell(1,surfaceNum);    %%costMatrix��Ӧ��һά����
%% cost function�ĳ�ʼ��
disp('Init cost function...');
for i=1:surfaceNum
    costMat = double((costImages{i}));
    costVector{i}=reshape(costMat,1,size(costMat,1)*size(costMat,2)*size(costMat,3));   %%�Ѿ���ת����һά�������㴦��
end
dims=size(costImages{1});   %%��ȡÿ����ͼ���ά�ȣ�ÿ����ͼ���С��һ����
%% ��ͼ��ͼ�����
disp('Begin construct graph...');
tic;
result = ConstructGraph(costVector,dims,delta_l,delta_u,delta_x,delta_y);    %%����C++����ͼ��ͼ�����
toc;

return