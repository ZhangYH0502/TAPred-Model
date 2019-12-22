function writeImage(image,layer,dir)
%% write image with the layer informations
%% input:
%%      image -- the input image
%%      layer -- the layer information(cell matrix)
%%      dir   -- the output Directory
mkdir(dir);
surfaceNum = size(layer,2);
[height,width,slice] = size(image);
for i = 1:slice
   Img = image(:,:,i);
   [IndexImg,map] = gray2ind(Img);
   RGBImg = ind2rgb(IndexImg,map);   
   for j = 1:width
       for k = 1:surfaceNum
            if k == 1
                RGBImg(layer{k}(i,j),j,1)=255;
                RGBImg(layer{k}(i,j),j,2)=0;
                RGBImg(layer{k}(i,j),j,3)=0;
            end
            if k == 2
                RGBImg(layer{k}(i,j),j,1)=255;
                RGBImg(layer{k}(i,j),j,2)=255;
                RGBImg(layer{k}(i,j),j,3)=0;
            end
            if k == 3
                RGBImg(layer{k}(i,j),j,1)=255;
                RGBImg(layer{k}(i,j),j,2)=0;
                RGBImg(layer{k}(i,j),j,3)=255;
            end
            if k == 4
                RGBImg(layer{k}(i,j),j,1)=0;
                RGBImg(layer{k}(i,j),j,2)=0;
                RGBImg(layer{k}(i,j),j,3)=255;
            end
            if k == 5
                RGBImg(layer{k}(i,j),j,1)=255;
                RGBImg(layer{k}(i,j),j,2)=0;
                RGBImg(layer{k}(i,j),j,3)=255;
            end
            if k == 6
                RGBImg(layer{k}(i,j),j,1)=0;
                RGBImg(layer{k}(i,j),j,2)=255;
                RGBImg(layer{k}(i,j),j,3)=255;
            end
       end
   end
   imwrite(RGBImg,[dir,num2str(i),'.bmp']);
end
return