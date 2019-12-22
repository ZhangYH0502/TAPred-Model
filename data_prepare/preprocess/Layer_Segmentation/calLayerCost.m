function [I_costOut] = calLayerCost(I_in,delta_l,methods)
%% 计算像素权重
%% I_in --- 表示输入图像
%% delta_l --- 表示面间限制
%% methods --- 表示方法，目前仅采用基于edge方法
[height,width,slice] = size(I_in);
numOfSurf = size(delta_l,2) + 1;
if size(methods,2) ~= numOfSurf     %需要分割的表面数需要与methods数选择一一对应
    error('unmatch methods number and surface Number!');
end

I_in_mat = separateImage(delta_l,I_in);    %分割图像
for i = 1:numOfSurf
   if strcmp(methods{i},'edge')            % 表示采用基于边缘的权重
       I_costOut{i} = edge_Cost(I_in_mat{i});     %采用基于边缘函数，目前采用基于中心差分的
   end
   if  strcmp(methods{i},'ori')
       I_costOut{i} = Ori_Cost(I_in_mat{i});
   end
   if  strcmp(methods{i},'edge1')
       I_costOut{i} = edge_Cost1(I_in_mat{i});
   end
end
return