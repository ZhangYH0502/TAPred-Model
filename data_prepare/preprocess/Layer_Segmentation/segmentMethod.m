function layer = segmentMethod(I,down_factor,cost_ind)
%% 主分割函数，对down_factor倍下采样的OCT图像进行3D层分割
% cost_ind: 0 represents dark-to-light matrix 
%           1 represents light-to-dark matrix
disp([num2str(down_factor) '倍下采样分割']);
[m,n,l] = size(I);

tic
if down_factor == 16    %% 如果采取32倍下采样，分割第一层和7,9,10三层的合并层，采用两层同时分割
    
    I_in = I(1:down_factor:m,:,1:l);
%     writeImg(I_in,'downSample16\');
%{
    delta_u15 = 20;%10 30
    delta_l15 = 2;%2 10
    delta_u57 = 10;
    delta_l57 = 2;%
    delta_u = [delta_u57,delta_u15];
    delta_l = [delta_l57,delta_l15];
    delta_x = [1,1,1];
    delta_y = [1,1,1];
 %}   
    %%2016-5-7
    delta_u15 = 10;%10 30
    delta_l15 = 5;%2 10
     delta_u56 = 10;
    delta_l56 = 2;%
    delta_u67 = 10;
    delta_l67 = 2;%
    delta_u = [delta_u67,delta_u56,delta_u15];
    delta_l = [delta_l67,delta_l56,delta_l15];
    delta_x = [1,1,1,1];
    delta_y = [1,1,1,1];
    %%
    
    I_costOut = calLayerCost(I_in,delta_l,{'edge1','ori','edge1','edge'});   %计算两个表面的权重,基于edge
    writeImg(I_costOut{2}/10,'cost16\');

    result = MultiGraphCut(I_costOut,delta_l,delta_u,delta_x,delta_y);
    
    %% 恢复各个子图像的表面
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    surfaceNum = size(I_costOut,2);
    subImagelength = size(I_costOut{1},1)*size(I_costOut{1},2)*size(I_costOut{1},3);
    out = restoreSurface(s_result,surfaceNum,subImagelength,delta_l);

    for i=1:surfaceNum
        outMatrix{i} = out((i-1)*subImagelength+1:i*subImagelength);
        outMatrix{i} = reshape(outMatrix{i},size(I_costOut{1}));
    end

    %% 找到各个层
    sumDelta_l = sum(delta_l);
    [subRows,subCols,subSlice] = size(outMatrix{1});
    for i = 1:surfaceNum
        for j = 1:subSlice
            for k = 1:subCols
                line = outMatrix{i}(:,k,j);
                tmp = find(line==0);
                 if(isempty(tmp))
                    tmp = 1;
                end
                layer{i}(j,k) = tmp(1)+sumDelta_l-1;
            end
        end
        if i == surfaceNum
            break;
        end
        sumDelta_l = sumDelta_l-delta_l(i);
    end
    %% 显示图像
    disp('保存结果...');
    tl{1} = layer{2};
    tl{2} = layer{3};
    writeImage(I_in,layer,'result16\');
%     writeImage(I_in,tl,'result161\');
end
toc
if down_factor == 8
    %{
    delta_u57 = 15;
    delta_l57 = 2;%
    delta_u = [delta_u57];
    delta_l = [delta_l57];
    I_costOut = calLayerCost(I,delta_l,{'ori','edge'});   %计算两个表面的权重,基于edge
    delta_x = [1,1];
    delta_y = [1,1];
    result = MultiGraphCut(I_costOut,delta_l,delta_u,delta_x,delta_y);
    
    %% 恢复各个子图像的表面
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    surfaceNum = size(I_costOut,2);
    subImagelength = size(I_costOut{1},1)*size(I_costOut{1},2)*size(I_costOut{1},3);
    out = restoreSurface(s_result,surfaceNum,subImagelength,delta_l);

    for i=1:surfaceNum
        outMatrix{i} = out((i-1)*subImagelength+1:i*subImagelength);
        outMatrix{i} = reshape(outMatrix{i},size(I_costOut{1}));
    end

    %% 找到各个层
    sumDelta_l = sum(delta_l);
    [subRows,subCols,subSlice] = size(outMatrix{1});
    for i = 1:surfaceNum
        for j = 1:subSlice
            for k = 1:subCols
                line = outMatrix{i}(:,k,j);
                tmp = find(line==0);
                 if(isempty(tmp))
                    tmp = 1;
                end
                layer{i}(j,k) = tmp(1)+sumDelta_l-1;
            end
        end
        if i == surfaceNum
            break;
        end
        sumDelta_l = sumDelta_l-delta_l(i);
    end
     %% 显示图像
    disp('保存结果...');
    writeImage(I,layer,'result168\');
%}
    
    [height,width,slice] = size(I);
    delta_x = 1;
    delta_y = 1;
    if cost_ind == 0
        I_costOut = edge_Cost(I);   %计算表面的权重,基于edge
    end
    if cost_ind == 1
        I_costOut = Ori_Cost(I);   %计算表面的权重,基于edge
    end
    if cost_ind == 2
        I_costOut = edge_Cost1(I);   %计算表面的权重,基于edge
    end
    costVector = reshape(I_costOut,1,size(I_costOut,1)*size(I_costOut,2)*size(I_costOut,3));
    result = ConstructGraphSingle1(costVector,size(I),delta_x,delta_y);
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    rTmp = restoreSurfaceSingle(s_result,I);
    r = reshape(rTmp,size(I));
    
    for j = 1:slice
        for k = 1:width
            line = r(:,k,j);
            tmp = find(line==0);
            if(isempty(tmp))
                tmp = 1;
            end
            layer{1}(j,k) = tmp(1);
        end
    end
    
end

if down_factor == 4
    %{
    delta_u57 = 20;
    delta_l57 = 2;%
    delta_u = [delta_u57];
    delta_l = [delta_l57];
    I_costOut = calLayerCost(I,delta_l,{'ori','edge'});   %计算两个表面的权重,基于edge
    delta_x = [1,1];
    delta_y = [1,1];
    result = MultiGraphCut(I_costOut,delta_l,delta_u,delta_x,delta_y);
    
    %% 恢复各个子图像的表面
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    surfaceNum = size(I_costOut,2);
    subImagelength = size(I_costOut{1},1)*size(I_costOut{1},2)*size(I_costOut{1},3);
    out = restoreSurface(s_result,surfaceNum,subImagelength,delta_l);

    for i=1:surfaceNum
        outMatrix{i} = out((i-1)*subImagelength+1:i*subImagelength);
        outMatrix{i} = reshape(outMatrix{i},size(I_costOut{1}));
    end

    %% 找到各个层
    sumDelta_l = sum(delta_l);
    [subRows,subCols,subSlice] = size(outMatrix{1});
    for i = 1:surfaceNum
        for j = 1:subSlice
            for k = 1:subCols
                line = outMatrix{i}(:,k,j);
                tmp = find(line==0);
                 if(isempty(tmp))
                    tmp = 1;
                end
                layer{i}(j,k) = tmp(1)+sumDelta_l-1;
            end
        end
        if i == surfaceNum
            break;
        end
        sumDelta_l = sumDelta_l-delta_l(i);
    end
     %% 显示图像
    disp('保存结果...');
    writeImage(uint8(I),layer,'result1684\');
 %}   
    
    [height,width,slice] = size(I);
    delta_x = 1;
    delta_y = 1;
    if cost_ind == 2
        I_costOut = Ori_Cost(I);   %计算表面的权重,基于edge edge_Cost(I)
    end
    if cost_ind == 1
        I_costOut = edge_Cost1(I);   %计算表面的权重,基于edge edge_Cost(I)
    end
    if cost_ind == 0
        I_costOut = edge_Cost(I);   %计算表面的权重,基于edge edge_Cost(I)
    end
    costVector = reshape(I_costOut,1,size(I_costOut,1)*size(I_costOut,2)*size(I_costOut,3));
    result = ConstructGraphSingle1(costVector,size(I),delta_x,delta_y);
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    rTmp = restoreSurfaceSingle(s_result,I);
    r = reshape(rTmp,size(I));
    
    for j = 1:slice
        for k = 1:width
            line = r(:,k,j);
            tmp = find(line==0);
             if(isempty(tmp))
                tmp = 1;
            end
            layer{1}(j,k) = tmp(1);
        end
    end
    
end
if down_factor == 2
    [height,width,slice] = size(I);
    delta_x = 1;
    delta_y = 1;
    if cost_ind ==1
        I_costOut = edge_Cost1(I);   %计算表面的权重,基于edge
    end
    if cost_ind ==2
        I_costOut = Ori_Cost(I);   %计算表面的权重,基于edge
    end
    if cost_ind == 0
        I_costOut = edge_Cost(I);   %计算表面的权重,基于edge
    end
    costVector = reshape(I_costOut,1,size(I_costOut,1)*size(I_costOut,2)*size(I_costOut,3));
    result = ConstructGraphSingle1(costVector,size(I),delta_x,delta_y);
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    rTmp = restoreSurfaceSingle(s_result,I);
    r = reshape(rTmp,size(I));
    
    for j = 1:slice
        for k = 1:width
            line = r(:,k,j);
            tmp = find(line==0);
            if isempty(tmp)
                tmp = 1;
            end
            layer{1}(j,k) = tmp(1);
        end
    end
end
if down_factor == 1
    [height,width,slice] = size(I);
    delta_x = 10;
    delta_y = 10;
    if cost_ind ==0
        I_costOut = edge_Cost(I);   %计算表面的权重,基于edge
    end
    if cost_ind ==1
        I_costOut = edge_Cost1(I);   %计算表面的权重,基于edge
    end
    if cost_ind ==2
        I_costOut = Ori_Cost(I); % ;
    end
    
    costVector = reshape(I_costOut,1,size(I_costOut,1)*size(I_costOut,2)*size(I_costOut,3));
%     if cost_ind ==2
%         result = ConstructGraphSingle1(costVector,size(I),delta_x,delta_y);
%     else
        result = ConstructGraphSingle1(costVector,size(I),delta_x,delta_y);
%     end
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    rTmp = restoreSurfaceSingle(s_result,I);
    r = reshape(rTmp,size(I));
    for j = 1:slice
        for k = 1:width
            line = r(:,k,j);
            tmp = find(line==0);
            if isempty(tmp)
                tmp = 1;
            end
            layer{1}(j,k) = tmp(1);
        end
    end
end

 %% 表示原图上7,9同时分割，本身不是0.79下采样的意思
if down_factor == 0.79 
    delta_u15 = 20;
    delta_l15 = 30;% normal eyes is 20  30,abnormal eyes are 5/2   
    delta_u = [delta_u15];
    delta_l = [delta_l15];
    I_costOut = calLayerCost(I,delta_l,{'ori','edge'});   %计算两个表面的权重,基于edge
    delta_x = [1,1];
    delta_y = [20,20];
    result = MultiGraphCut(I_costOut,delta_l,delta_u,delta_x,delta_y);
    
    %% 恢复各个子图像的表面
    disp('恢复表面...');
    temp = find(result~=0);
    s_result = result(1:size(temp,2));
    surfaceNum = size(I_costOut,2);
    subImagelength = size(I_costOut{1},1)*size(I_costOut{1},2)*size(I_costOut{1},3);
    out = restoreSurface(s_result,surfaceNum,subImagelength,delta_l);

    for i=1:surfaceNum
        outMatrix{i} = out((i-1)*subImagelength+1:i*subImagelength);
        outMatrix{i} = reshape(outMatrix{i},size(I_costOut{1}));
    end

    %% 找到各个层
    sumDelta_l = sum(delta_l);
    [subRows,subCols,subSlice] = size(outMatrix{1});
    mkdir('outMatrix\');
    for i = 1:surfaceNum
        for j = 1:subSlice
            for k = 1:subCols
                line = outMatrix{i}(:,k,j);
                tmp = find(line==0);
                if isempty(tmp)
                    tmp = 2;
                end
                layer{i}(j,k) = tmp(1)+sumDelta_l-1;
            end
        end
        if i == surfaceNum
            break;
        end
        sumDelta_l = sumDelta_l-delta_l(i);
    end
%     writeImage(I/max(max(max(I))),layer,'outMatrix\');
end
return