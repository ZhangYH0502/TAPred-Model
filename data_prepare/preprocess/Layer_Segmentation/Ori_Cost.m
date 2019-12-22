function imgcost = Ori_Cost(img3d)
[m,n,dim] = size(img3d);
for num = 1:dim
    img = double(img3d(:,:,num));
    img1 = -img;
    img1 = (img1-min(img1(:)))/(max(img1(:))-min(img1(:)));

    [~,gradImg] = gradient(img,2,2);
    gradImg = -1*gradImg;
    gradImg = (gradImg-min(gradImg(:)))/(max(gradImg(:))-min(gradImg(:)));
    
    imgcost(:,:,num) = ceil((img1*0.1 + gradImg*0.9)*10)+1E-5;%+imopenl2d
end
end