clc;
clear all;

path_in = 'F:\zhangyuhan\GA_tmp\combined results';
path_in_opticflow = 'F:\zhangyuhan\GA_tmp\opticflow';

path_out = 'F:\zhangyuhan\GA_tmp\testing for 3DUNet';

img = double(imread([path_in '\' '1.bmp']));
img = img./255;

opticflow = double(imread([path_in_opticflow '\' '1.bmp']));
opticflow = opticflow./80;

sample_all = zeros(448,448,3);
sample_all(:,:,1:3) = img;
sample_all(:,:,4) = opticflow;

k = 0;
for m = 1:112:337
    for n = 1:112:337
        sample = sample_all(m:m+111, n:n+111,:);
        k = k+1;
        save([path_out '\' num2str(k) '.mat'], 'sample', '-v7.3');
    end
end