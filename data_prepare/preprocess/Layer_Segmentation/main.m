%% 主函数，用来分割OCT图像

function main()
disp('读取图像');
[path_Name,I] = read3Dimg();
ind = find(path_Name=='\');
FileName = path_Name((ind(length(ind))+1):length(path_Name));
[height,width,slice] = size(I);

cost_ind0=0;
cost_ind1=1;
cost_ind2=2;
tic;
down_factor = 16;         %轴向下采样初始化值
tic;
layer16 = segmentMethod(I,down_factor,cost_ind0);   %首先先进行16倍下采样，得到该尺度下ILM表面以及7,8,10三个表面
toc;
% 中间输出结果
down_factor = 8;
I_down8 = I(1:down_factor:height,:,1:slice);
for i = 1:size(layer16,2)
    layer8coarse{i} = layer16{i}*2;    %得到8倍下采样的粗结果
end
%  writeImage(I_down8,layer8coarse,'coarseResult8\');
 
%  layer8coarse1 = layer8coarse{1};
%  x=1:size(I,2);
%  for i = 1:1
%     for j = 1:128
%         p = polyfit(x,layer8coarse1(j,:),2);
%         y = polyval(p,x);
%         layer8coarse{i}(j,:) = ceil(y)-1;%floor(smooth(layer2{i}(j,:),5));
%     end
%  end
%   writeImage(I_down8,layer8coarse,'coarseResult81\');
  layer8coarse1 = layer8coarse; 
  layer8coarse1 = layer8coarse; 
  layer8coarse = [];
  layer8coarse{1} = layer8coarse1{2};
  layer8coarse{2} = layer8coarse1{3};
%% level 2下的分割
for surNum = 1:size(layer8coarse,2)
    
    % defined search range
    if surNum == 0
        coarse = layer8coarse{surNum};
        up = max(coarse-5,1);
        down = up + 10;
    end
    
    if surNum == 1
        coarse = layer8coarse{surNum};
        diff = max(max(coarse-layer8coarse{surNum}));
        up = max(coarse-5,1);
        down = up + 10;
    end
    
    if surNum == 2
        coarse = layer8coarse{surNum};
        up = max(coarse-5,1);%3
        down = up + 10;%6
    end
    
    Imat8 = [];
    for i = 1:slice
        for j = 1:width
            Imat8(:,j,i) = I_down8(up(i,j):down(i,j),j,i);
        end
    end
    
    if surNum == 0
        tic;
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind2);
        toc;
    end
    if surNum == 1
        tic;
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind1);
        toc;
        ll{1} = layer8{surNum};
%         writeImage(I_down8,ll,'result81\');
        
    end
    if surNum == 2
        tic;
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind0);
        toc;
    end
    
    layer8{surNum} = layer8{surNum} + up - 1;
end
for i = 2:size(layer8,2)
    for j = 1:128
        layer8{i}(j,:) = floor(smooth(layer8{i}(j,:),5));
    end
end
 writeImage(I_down8,layer8,'result8\');


for i = 1:size(layer8,2)
    layer4coarse{i} = layer8{i}*2;    %得到4倍下采样的粗结果
end
% 中间输出结果
down_factor = 4;
I_down4 = I(1:down_factor:height,:,1:slice);
% writeImage(I_down4,layer4coarse,'coarseResult4\');

% layer4coarse1 = layer4coarse{1};
%  x=1:size(I,2);
%  for i = 1:1
%     for j = 1:128
%         p = polyfit(x,layer4coarse1(j,:),2);
%         y = polyval(p,x);
%         layer4coarse{i}(j,:) = ceil(y)-2;%floor(smooth(layer2{i}(j,:),5));
%     end
%  end
%   writeImage(I_down4,layer4coarse,'coarseResult41\');
%% level 3下的分割
for surNum = 1:size(layer8,2)
    coarse = layer4coarse{surNum};
    up = max(coarse-3,1);
    down = up + 6;
    for i = 1:slice
        for j = 1:width
            Imat4(:,j,i) = I_down4(up(i,j):down(i,j),j,i);
        end
    end
    tic;
    if surNum ==0
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind1);
    end
    if surNum ==1
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind2);
    end
    if surNum == 2
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind0);
    end
    layer4{surNum} = layer4{surNum} + up - 1;
end
toc;
for i = 1:size(layer4,2)
    for j = 1:128
        layer4{i}(j,:) = floor(smooth(layer4{i}(j,:),5));
    end
end
%  writeImage(I_down4,layer4,'result4\');


for i = 1:size(layer4,2)
    layer2coarse{i} = layer4{i}*2;    %得到2倍下采样的粗结果
end
% 中间输出结果
down_factor = 2;
I_down2 = I(1:down_factor:height,:,1:slice);
%  writeImage(I_down2,layer2coarse,'coarseResult2\');
 
%  layer2coarse1 = layer2coarse{1};
%  x=1:size(I,2);
%  for i = 1:1
%     for j = 1:128
%         p = polyfit(x,layer2coarse1(j,:),2);
%         y = polyval(p,x);
%         layer2coarse{i}(j,:) = ceil(y)-2;%floor(smooth(layer2{i}(j,:),5));
%     end
%  end
%   writeImage(I_down2,layer2coarse,'coarseResult21\');
  
%% level 2下的分割
for surNum = 1:size(layer4,2)
    coarse = layer2coarse{surNum};
    up = max(coarse-5,1);
    down = up + 10;
    for i = 1:slice
        for j = 1:width
            Imat2(:,j,i) = I_down2(up(i,j):down(i,j),j,i);
        end
    end
    tic;
    if surNum ==0
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind1);
    end
    if surNum ==1
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind2);
    end
    
    if surNum ==2
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind0);
    end
    toc;
    layer2{surNum} = layer2{surNum} + up - 1;
end
for i = 1:size(layer2,2)
    for j = 1:128
        layer2{i}(j,:) = floor(smooth(layer2{i}(j,:),5));
    end
end
%  writeImage(I_down2,layer2,'result2\');

for i = 1:size(layer2,2)
    layercoarse{i} = layer2{i}*2;    %得到原图的粗结果
end

layercoarse1 = layercoarse;
x=1:size(I,2);
for i = 1:1%size(layer2,2)
    for j = 1:128
        p = polyfit(x,(layercoarse{i}(j,:)),2);
        y = polyval(p,x);
        layercoarse{i}(j,:) = ceil(y);%floor(smooth(layer2{i}(j,:),5));
    end
end

down_factor = 1;
I_down = I(1:down_factor:height,:,1:slice);
% writeImage(I_down,layercoarse1,'coarseResult\');
% writeImage(I_down,layercoarse,'coarseResult11\');
%% RPE corrected
coarse = layercoarse1{1};
up = max(coarse-5,1);
down = up + 10;
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l2 = segmentMethod(Imat,down_factor,cost_ind2);
l2{1} = l2{1} + up - 1;

lp{1} = l2{1};
lp{2} = layercoarse1{2};

    for i = 1:size(lp,2)
        for j = 1:128
            lp{i}(j,:) = ceil(smooth(lp{i}(j,:),0.02,'lowess'));%ceil(smooth(LayerPos{i}(j,:),5));
        end
    end

writeImage(I_down,lp,'Result33\');


%% level 1下的分割 BM layer
% x=1:size(I,2);
%     for j = 1:128
%         p = polyfit(x,(lp{2}(j,:)),2);
%         y = polyval(p,x);
%         lp2{1}(j,:) = ceil(y);%floor(smooth(layer2{i}(j,:),5));
%     end
%     writeImage(I_down,lp2,'coarseResult11\');
    Imat =[];
coarse = layercoarse{1};
up = max(coarse,1);
down = up + 50;
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l1 = segmentMethod(Imat,down_factor,cost_ind1);
l1{1} = l1{1} + up - 1;


lp1{2} = lp{1};
lp1{3} = lp{2};

 for i = 1:size(l1,2)
        for j = 1:128
            lp1{i}(j,:) = ceil(smooth(l1{i}(j,:),0.05,'lowess'));%ceil(smooth(LayerPos{i}(j,:),5));
        end
 end

writeImage(I_down,lp1,'Result\');


%% segmenting the RPE layer in the level 1
%{
Imat=[];

 BMlayer = l1{1};

coarseISOS = layercoarse1{1};
diff = max(max(BMlayer - coarseISOS));
up = max(l1{1}-diff,1);
down = up + diff;

for i = 1:slice
    for j = 1:width
        if up(i,j)>down(i,j)
            Imat(:,j,i) = I_down(down(i,j)-3:down(i,j),j,i);
        else
            Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
        end
    end
end
l2 = segmentMethod(Imat,down_factor,cost_ind0);
l2{1} = l2{1} + up - 1;
writeImage(I_down,l2,'rpeResult\');
%}
%{
%% segmenting the ISOS layer in the level 1
Imat=[];
coarse = layercoarse{1};
%up = max(coarse-2,1);
up = l2{1}-20;
down = l2{1}-3;
for i = 1:slice
    for j = 1:width
        if up(i,j)>down(i,j)
            Imat(:,j,i) = I_down(down(i,j)-3:down(i,j),j,i);
        else
            Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
        end
    end
end
l3 = segmentMethod(Imat,down_factor,cost_ind0);
l3{1} = l3{1} + up - 1;
writeImage(I_down,l3,'ISOSResult\');

%}


%% 下面两层同时分割，利用down_factor = 0.79 表示下面两层同时分割 ,revised at 5.11
%% AMD data processing
%{
flag = 1;
down_factor = 0.79;
coarse = lp1{2};
up = max(coarse-30,1);
down = up+41;

Imat = [];
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
lis = segmentMethod(Imat,down_factor,cost_ind0);
lis{1} = lis{1} + up - 1;
lis{2} = lis{2} + up - 1;

for i = 1:size(lis,2)
    for j = 1:128
        lis{i}(j,:) = floor(smooth(lis{i}(j,:),5));
    end
end
writeImage(I_down,lis,'result1111\');
layerPos{1}=lp1{1};
layerPos{2}=lis{1};
layerPos{3}=lis{2};
layerPos{4} = layercoarse1{2};
save 222.mat 'layerPos';
writeImage(I_down,layerPos,'AMD\');
%}
%%

%% 下面两层同时分割，利用down_factor = 0.79 表示下面两层同时分割
% normal eyes
down_factor = 0.79;
BMlayer = l1{1};
coarseISOS = layercoarse1{1};
diff = max(max(BMlayer - coarseISOS));
up = max(BMlayer-diff-5,1);
down = BMlayer;

Imat = [];
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l22 = segmentMethod(Imat,down_factor,cost_ind0);
l22{1} = l22{1} + up -1;
l22{2} = l22{2} + up -1;
layer{1} = l1{1};
layer{2} = l22{1};
layer{3} = l22{2};

for i = 1:size(layer,2)
    for j = 1:128
        layer{i}(j,:) = floor(smooth(layer{i}(j,:),5));
    end
end
% writeImage(I_down,layer,'result1\');
layerPos=layer;
layerPos{4} = layercoarse1{2};
toc;
% save 821OS.mat 'layerPos';


%% correct ILM layer
cd 'ILMsegmentation'
out = main([path_Name '\']);
cd ..
layerPos{4} = out;
writeImage(I_down,layerPos,['result1\' FileName '\']);
% [X,Y] = meshgrid(1:(width/slice):width,1:width);
% [Xh,Yh] = meshgrid(1:width,1:width);
% B_scan_dis=1000;
% out1=out';
% RPE_Dw_Im=round(gridfit(X(:), Y(:), out1(:),[1:(width/slice):width], Y(1:width), 'smoothness',[(slice/0.001)*(1/(B_scan_dis)),slice/(0.001)],'regularizer', 'diffusion' ));
% out = RPE_Dw_Im';
save(['LayerSegRes\' FileName '.mat'],'layerPos');
%% post-processing 
%{
isosLayer1 = layer{3};      % isos Layer segmented by two layers simultaneously
rpeLayer = layer{2};        % rpe Layer segmented by two layers simultaneously
isosLayer0 = layercoarse1{1};  % isos Layer segmented by multiscale
diff1 = isosLayer1-isosLayer0;  % computing the difference of isos layer to adjust the isos Layer position
diffTh = 10; % 2 DRUSEN; 5、10 GA
isosLayer1(diff1>diffTh) = isosLayer0(diff1>diffTh)-1; 
rpeLayer(diff1>diffTh) = isosLayer0(diff1>diffTh);

LayerPos{1} = l1{1}; % BM Layer
LayerPos{2} = rpeLayer;
LayerPos{3} = isosLayer1;
LayerPos{4} = layercoarse1{2}; % ILM Layer

for i = 1:size(LayerPos,2)
    for j = 1:128
        LayerPos{i}(j,:) = ceil(smooth(LayerPos{i}(j,:),0.01,'lowess'));%ceil(smooth(LayerPos{i}(j,:),5));
    end
end
filename = ['P141674020100713OS.mat'];
save (filename,'LayerPos') 
writeImage(I_down,LayerPos,'result11\');
%}
 
return