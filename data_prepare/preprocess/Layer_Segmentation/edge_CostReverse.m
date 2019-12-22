function imgcost = edge_CostReverse(img3d)
[m,n,dim] = size(img3d);
for num = 1:dim
    img = double(img3d(:,:,num));
    % get vertical gradient image
    [~,gradImg] = gradient(img,2,-2);
    gradImg = -1*gradImg;
    
    % normalize gradient
    gradImg = (gradImg-min(gradImg(:)))/(max(gradImg(:))-min(gradImg(:)));
    % get the "invert" of the gradient image.
    gradImgMinus = gradImg;%*-1+1; 
    %{
    I_canny = canny_edge(img,'canny',[0,0.2,0.6]);
    gI = img(2:size(img,1),:)-img(1:size(img,1)-1,:);
    gI(size(img,1),:)=0;
    gI(gI<3)=0;
    %gI(gI>1)=1;
    imwrite(gI,['midresult/',num2str(num),'.bmp']);
    %}
    imgcost(:,:,num) = ceil(gradImgMinus*10)+1E-5;;%+imopenl2d
end
end