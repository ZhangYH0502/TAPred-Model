function imgcost = edge_Cost1(img3d)
[m,n,dim] = size(img3d);
for num = 1:dim
    img = double(img3d(:,:,num));
    % get vertical gradient image
    [~,gradImg] = gradient(img,2,2);
    %gradImg(gradImg<0)=0;
    % normalize gradient
    gradImg = (gradImg-min(gradImg(:)))/(max(gradImg(:))-min(gradImg(:)));
    %gradImg = 0.8*gradImg+0.2*img1;
    % get the "invert" of the gradient image.
    gradImgMinus = gradImg*-1+1;%; 

    imgcost(:,:,num) = ceil(gradImg*10)+1E-5;%+imopenl2d
end
end