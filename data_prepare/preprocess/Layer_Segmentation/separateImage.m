function matrixOut=separateImage(delta_l,image)
%%%% 函数名:separateImage
%% 函数功能:将原图像根据相应的参数，分割成对应的子图像
%% 分割的效果是为了消除不必要的区域，降低空间复杂度
%% 参数说明:
%% image      ---图像源数据，是3D图像
%% delta_l    ---面与面之间最小距离的序列, 与delta_u里面的值一一对应
%% 传入时保证delta_l不能为空


[height,width,slice]=size(image);
sum_delta_l=sum(delta_l);       %%计算出delta_l所有值的和
up=0;                           %%初始化子图像的上下范围
down=sum_delta_l;               %%初始化子图像的上下范围
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