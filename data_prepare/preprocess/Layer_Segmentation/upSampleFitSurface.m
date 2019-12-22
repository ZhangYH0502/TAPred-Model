function layout = upSampleFitSurface(layer,image_org,down_factor)
%% ���²����Ľ�������ϲ�����ֵ
%% ����������ֵ�ҵ�RPE�±��棬Ȼ�����ø��±�������ƽ����
%% ����˵����
%% input��layer---�±���ָ���
%%        image_org --- ԭʼͼ��
%%        down_factor --- ��ʾ�²�������
%% out:   layout  ---��ʾ����Ĳ�Ľ��
surfaceNum = size(layer,2);             % ��������
down_cols = size(layer{1},2);          %�²������
[rows,cols,slices] = size(image_org);

[X,Y] = meshgrid(1:down_factor:cols,1:slices);
[X_out,Y_out] = meshgrid(1:cols,1:slices);
for i = 1:surfaceNum
    layer{i} = layer{i} * down_factor;      
end

for i = 1:surfaceNum
    center = [];
    value = [];
    count = 1;
    for j = 1:slices
        x = X(j,:);
        y = Y(j,:);
        
        x1 = [x,x];
        y1 = [y,y+1];
        center = [x1;y1];
        value = layer{i}(j,:);
        value = [value,value];
        st{i}(j) = tpaps(center,value);
        
        x = X_out(j,:);
        y = Y_out(j,:);
        var = [x;y];
        layout{i}(j,:) = ceil(fnval(st{i}(j),var));
    end
end
%     for j = 1:down_factor:cols
%         x = X(:,ceil(j/down_factor))';
%         y = Y(:,ceil(j/down_factor))';
%         value = [value,layer{i}(:,count)'];
%         center = [center,[x;y]];
%         count = count + 1;
%     end
%     layout{i} = ceil(interp2(X,Y,layer{i},X_out,Y_out,'spline'));
    %{
    tic;
    st{i} = tpaps(center,value,0.2);    
    toc;
    var = [];
    for j = 1:cols
        x = X_out(:,j)';
        y = Y_out(:,j)';
        var = [var,[x;y]]; 
    end
    layout{i} = ceil(fnval(st{i},var));
    layout{i} = reshape(layout{i},slices,size(layout{i},2)/slices);
    %}
return