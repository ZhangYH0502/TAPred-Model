clc;
clear all;

path_in = 'testing_for_3DUNET';
path_in_opticflow = 'opticflow_for_3DUNET_test';

path_out = 'testing';

for i = 1:1
    disp(num2str(i));
    
    if ~exist([path_in '\' num2str(i) '.bmp'],'file')
        continue;
    end
    
    mkdir([path_out '\' num2str(i)]);
    
    img = double(imread([path_in '\' num2str(i) '.bmp']));
    img = img./255;
    
    opticflow = double(imread([path_in_opticflow '\' num2str(i) '.bmp']));
    opticflow = opticflow./80;
    
    sample_all = zeros(448,448,3);
    sample_all(:,:,1:3) = img;
    sample_all(:,:,4) = opticflow;
    
    k = 0;
    for m = 1:112:337
        for n = 1:112:337
            sample = sample_all(m:m+111, n:n+111,:);      
            k = k+1;
            save([path_out '\' num2str(i) '\' num2str(k) '.mat'], 'sample', '-v7.3');     
        end
    end
end