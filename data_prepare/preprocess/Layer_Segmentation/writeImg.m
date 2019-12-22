function writeImg(image,dir)
mkdir(dir);
[height,width,slice] = size(image);
for i = 1:slice
   Img = image(:,:,i);
   imwrite((Img),[dir,num2str(i),'.bmp']);
end
end