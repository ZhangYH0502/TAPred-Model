%% �������������ָ�OCTͼ��

function main()
disp('��ȡͼ��');
[path_Name,I] = read3Dimg();
[height,width,slice] = size(I);

cost_ind0=0;
cost_ind1=1;
cost_ind2=2;

down_factor = 16;         %�����²�����ʼ��ֵ
layer16 = segmentMethod(I,down_factor,cost_ind0);   %�����Ƚ���16���²������õ��ó߶���ILM�����Լ�7,8,10��������

% �м�������
down_factor = 8;
I_down8 = I(1:down_factor:height,:,1:slice);
for i = 1:size(layer16,2)
    layer8coarse{i} = layer16{i}*2;    %�õ�8���²����Ĵֽ��
end
 writeImage(I_down8,layer8coarse,'coarseResult8\');
 
 layer8coarse1 = layer8coarse{1};
 x=1:size(I,2);
 for i = 1:1
    for j = 1:128
        p = polyfit(x,layer8coarse1(j,:),2);
        y = polyval(p,x);
        layer8coarse{i}(j,:) = ceil(y)-1;%floor(smooth(layer2{i}(j,:),5));
    end
 end
  writeImage(I_down8,layer8coarse,'coarseResult81\');
%% level 2�µķָ�
%{
coarse = layer8coarse{1};
diff = max(max(coarse-layer8coarse{2}));
up = max(layer8coarse{2}-2,1);
down = up + diff+15;
Imat8 = [];
    for i = 1:slice
        for j = 1:width
            Imat8(:,j,i) = I_down8(up(i,j):down(i,j),j,i);
        end
    end
layer8 = segmentMethod(Imat8,down_factor,cost_ind0);
for i=1:2
    layer8{i} = layer8{i} + up - 1;
end

for i = 1:size(layer8,2)
    for j = 1:128
        layer8{i}(j,:) = floor(smooth(layer8{i}(j,:),5));
    end
end
 writeImage(I_down8,layer8,'result8\');


for i = 1:size(layer8,2)
    layer4coarse{i} = layer8{i}*2;    %�õ�4���²����Ĵֽ��
end
% �м�������
down_factor = 4;
I_down4 = I(1:down_factor:height,:,1:slice);
 writeImage(I_down4,layer4coarse,'coarseResult4\');
 %}

for surNum = 1:size(layer16,2)
    
    % defined search range
    if surNum == 1
        coarse = layer8coarse{surNum};
        up = max(coarse-5,1);
        down = up + 10;
    end
    
    if surNum == 2
        coarse = layer8coarse{2};
        diff = max(max(coarse-layer8coarse{surNum}));
        up = max(coarse-5,1);
        down = up + 10;
    end
    
    if surNum == 3
        coarse = layer8coarse{surNum};
        up = max(coarse-3,1);
        down = up + 6;
    end
    
    Imat8 = [];
    for i = 1:slice
        for j = 1:width
            Imat8(:,j,i) = I_down8(up(i,j):down(i,j),j,i);
        end
    end
    
    if surNum == 1
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind2);
    end
    if surNum == 2
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind1);
    end
    if surNum == 3
        layer8(surNum) = segmentMethod(Imat8,down_factor,cost_ind0);
    end
    
    layer8{surNum} = layer8{surNum} + up - 1;
end
for i = 1:size(layer8,2)
    for j = 1:128
        layer8{i}(j,:) = floor(smooth(layer8{i}(j,:),5));
    end
end
 writeImage(I_down8,layer8,'result8\');


for i = 1:size(layer8,2)
    layer4coarse{i} = layer8{i}*2;    %�õ�4���²����Ĵֽ��
end
% �м�������
down_factor = 4;
I_down4 = I(1:down_factor:height,:,1:slice);
 writeImage(I_down4,layer4coarse,'coarseResult4\');

layer4coarse1 = layer4coarse{1};
 x=1:size(I,2);
 for i = 1:1
    for j = 1:128
        p = polyfit(x,layer4coarse1(j,:),2);
        y = polyval(p,x);
        layer4coarse{i}(j,:) = ceil(y)-2;%floor(smooth(layer2{i}(j,:),5));
    end
 end
  writeImage(I_down4,layer4coarse,'coarseResult41\');
%% level 3�µķָ�
%{
Imat4 = [];
 coarse = layer4coarse{2};
 diff = max(max(layer4coarse{2}-coarse));
 up = max(coarse-2,1);
 down = up + diff +20;
 for i = 1:slice
     for j = 1:width
            Imat4(:,j,i) = I_down4(up(i,j):down(i,j),j,i);
     end
 end
layer4 = segmentMethod(Imat4,down_factor,cost_ind2);
for surNum =1:2
    layer4{surNum} = layer4{surNum} + up - 1;
end
%}

for surNum = 1:size(layer8,2)
    coarse = layer4coarse{surNum};
    up = max(coarse-3,1);
    down = up + 6;
    for i = 1:slice
        for j = 1:width
            Imat4(:,j,i) = I_down4(up(i,j):down(i,j),j,i);
        end
    end
    if surNum ==1
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind1);
    end
    if surNum ==2
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind2);
    end
    if surNum == 3
        layer4(surNum) = segmentMethod(Imat4,down_factor,cost_ind0);
    end
    layer4{surNum} = layer4{surNum} + up - 1;
end

for i = 1:size(layer4,2)
    for j = 1:128
        layer4{i}(j,:) = floor(smooth(layer4{i}(j,:),5));
    end
end
 writeImage(I_down4,layer4,'result4\');


for i = 1:size(layer4,2)
    layer2coarse{i} = layer4{i}*2;    %�õ�2���²����Ĵֽ��
end
% �м�������
down_factor = 2;
I_down2 = I(1:down_factor:height,:,1:slice);
 writeImage(I_down2,layer2coarse,'coarseResult2\');
 
 layer2coarse1 = layer2coarse{1};
 x=1:size(I,2);
 for i = 1:1
    for j = 1:128
        p = polyfit(x,layer2coarse1(j,:),2);
        y = polyval(p,x);
        layer2coarse{i}(j,:) = ceil(y)-2;%floor(smooth(layer2{i}(j,:),5));
    end
 end
  writeImage(I_down2,layer2coarse,'coarseResult21\');
  
%% level 2�µķָ�
for surNum = 1:size(layer4,2)
    coarse = layer2coarse{surNum};
    up = max(coarse-5,1);
    down = up + 10;
    for i = 1:slice
        for j = 1:width
            Imat2(:,j,i) = I_down2(up(i,j):down(i,j),j,i);
        end
    end
    if surNum ==1
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind1);
    end
    if surNum ==2
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind2);
    end
    
    if surNum ==3
        layer2(surNum) = segmentMethod(Imat2,down_factor,cost_ind0);
    end
    layer2{surNum} = layer2{surNum} + up - 1;
end
for i = 1:size(layer2,2)
    for j = 1:128
        layer2{i}(j,:) = floor(smooth(layer2{i}(j,:),5));
    end
end
 writeImage(I_down2,layer2,'result2\');

for i = 1:size(layer2,2)
    layercoarse{i} = layer2{i}*2;    %�õ�ԭͼ�Ĵֽ��
end

layercoarse1 = layercoarse;
x=1:size(I,2);
for i = 1:1%size(layer2,2)
    for j = 1:128
        p = polyfit(x,(layercoarse{i}(j,:)),2);
        y = polyval(p,x);
        layercoarse{i}(j,:) = ceil(y)-2;%floor(smooth(layer2{i}(j,:),5));
    end
end

down_factor = 1;
I_down = I(1:down_factor:height,:,1:slice);
writeImage(I_down,layercoarse1,'coarseResult\');
 

% RPE conrrected
coarse = layercoarse1{2};
up = max(coarse-5,1);
down = up + 10;
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l2 = segmentMethod(Imat,down_factor,cost_ind2);
l2{1} = l2{1} + up - 1;

lp{2} = l2{1};
lp{1} = layercoarse1{1};
lp{3} = layercoarse1{3};

% x=1:size(I,2);
% for i = 1:1%size(layer2,2)
%     for j = 1:128
%         p = polyfit(x,(lp{i}(j,:)),4);
%         y = polyval(p,x);
%         lp{i}(j,:) = ceil(y);%floor(smooth(layer2{i}(j,:),5));
%     end
% end

    for i = 1:size(lp,2)
        for j = 1:128
            if i ==1 
                lp{i}(j,:) = ceil(smooth(lp{i}(j,:),0.05,'lowess'));%ceil(smooth(LayerPos{i}(j,:),5));
            else
                lp{i}(j,:) = ceil(smooth(lp{i}(j,:),0.01,'lowess'));%ceil(smooth(LayerPos{i}(j,:),5));
            end
        
        end
    end

writeImage(I_down,lp,'Result33\');


%% level 1�µķָ� BM layer
x=1:size(I,2);
    for j = 1:128
        p = polyfit(x,(lp{2}(j,:)),2);
        y = polyval(p,x);
        lp2{1}(j,:) = ceil(y);%floor(smooth(layer2{i}(j,:),5));
    end
    writeImage(I_down,lp2,'coarseResult11\');
    Imat =[];
coarse = lp2{1};
up = max(coarse,1);
down = up + 50;
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l1 = segmentMethod(Imat,down_factor,cost_ind1);
l1{1} = l1{1} + up - 1;

lp1{1} = l1{1};
writeImage(I_down,lp1,'Result\');
%dlmwrite('ILM.txt',l1{1},' ');


%% segmenting the RPE layer in the level 1
Imat=[];
%coarse = layercoarse{1};
%up = max(coarse-2,1);

 BMlayer = l1{1};
%  coarseISOS = layercoarse1{1};
% diff = max(max(BMlayer - coarseISOS));
%  up = max(coarseISOS-2,1);
%  down = up + 13;

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
%% ��������ͬʱ�ָ����down_factor = 0.79 ��ʾ��������ͬʱ�ָ�
down_factor = 0.79;

% coarse = layercoarse1{1};
% up = max(coarse-50,1);
% down = up + 50;

BMlayer = l1{1};
coarseISOS = layercoarse1{1};
diff = max(max(BMlayer - coarseISOS));
up = max(BMlayer-diff,1);
down = BMlayer;

Imat = [];
for i = 1:slice
    for j = 1:width
        Imat(:,j,i) = I_down(up(i,j):down(i,j),j,i);
    end
end
l2 = segmentMethod(Imat,down_factor,cost_ind0);
l2{1} = l2{1} + up -1;
l2{2} = l2{2} + up -1;
layer{1} = l1{1};
layer{2} = l2{1};
layer{3} = l2{2};

for i = 1:size(layer,2)
    for j = 1:128
        layer{i}(j,:) = floor(smooth(layer{i}(j,:),5));
    end
end
writeImage(I_down,layer,'result1\');

%% post-processing 
isosLayer1 = layer{3};      % isos Layer segmented by two layers simultaneously
rpeLayer = layer{2};        % rpe Layer segmented by two layers simultaneously
isosLayer0 = layercoarse1{1};  % isos Layer segmented by multiscale
diff1 = isosLayer1-isosLayer0;  % computing the difference of isos layer to adjust the isos Layer position
diffTh = 10; % 2 DRUSEN; 5��10 GA
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

 %% ���Ƿֵ�8��
%  ILM = layer{1};
%  ISOS = layer{3};
%  layer910 = layer{2};
%  I_cost = edge_CostReverse(I);   %��������Ȩ��,����edge
%  maxCost = max(max(max(I_cost)));
%  I_costOut = ones(size(I_cost))*maxCost;
%  for i = 1:slice
%      for j = 1:width
%          I_costOut(ISOS(i,j):layer910(i,j),j,i) = I(ISOS(i,j):layer910(i,j),j,i);
%      end
%  end
%  
return