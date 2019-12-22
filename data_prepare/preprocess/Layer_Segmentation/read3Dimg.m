function [path_name,I] = read3Dimg()
%read 3D bmp oct retinal images
path_name = uigetdir('E:\shijiajia\Doctor_Study\vessel detection\BFDenoiseImg');
dims = [1024 512 128];
height = dims(1);
width = dims(2);
slice = dims(3);
for i = 1:slice
    I(:,:,i) = imread([path_name '\' num2str(i) '.bmp']);
end
return