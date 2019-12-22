function result = MultiGraphCut1(costImages,delta_l,delta_u,delta_x,delta_y)
%%%%函数名:MultiGraphCut
%%函数功能:图割程序函数,包括cost function计算，构图以及最大流最小割的计算
%%参数说明:
%% costImages    ---分割之后的权值子图像
%% delta_l         ---面间最小距离数组(可变模型改成cell类型)
%% delta_u         ---面间最大距离数组（可变模型改成cell类型）
%% delta_x         ---列间限制x
%% delta_y         ---列间限制y
%% result          ---图割程序运行后满足条件的点的结果

surfaceNum = size(costImages,2);    %%获得子图像，即需要分割的表面数目
if surfaceNum ~= size(delta_x,2) || surfaceNum ~= size(delta_y,2)
    error('the surfaceNum and the size of delta_x or delta_y is not matched!');
end
costVector=cell(1,surfaceNum);    %%costMatrix对应的一维向量
%% cost function的初始化
disp('Init cost function...');
for i=1:surfaceNum
    costMat = double((costImages{i}));
    costVector{i}=reshape(costMat,1,size(costMat,1)*size(costMat,2)*size(costMat,3));   %%把矩阵转换成一维向量方便处理
end
dims=size(costImages{1});   %%获取每个子图像的维度，每个子图像大小是一样的
%% 构图及图割程序
disp('Begin construct graph...');
tic;
result = ConstructGraph(costVector,dims,delta_l,delta_u,delta_x,delta_y);    %%利用C++处理构图及图割程序
toc;

return