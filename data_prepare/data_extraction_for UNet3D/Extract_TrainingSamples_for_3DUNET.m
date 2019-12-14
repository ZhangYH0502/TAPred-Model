clc;
clear all;

path_in = 'training_for_3DUNET';
path_in_opticflow = 'opticflow_for_3DUNET';
path_in_label = 'labels_for_3DUNET';

path_out = 'training';
mkdir(path_out);

k = 0;
for i = 1:22
    disp(num2str(i));
    
    img = double(imread([path_in '\' num2str(i) '.bmp']));
    img = img./255;
    
    opticflow = double(imread([path_in_opticflow '\' num2str(i) '.bmp']));
    opticflow = opticflow./80;
    
    sample_all = zeros(448,448,4);
    sample_all(:,:,1:3) = img;
    sample_all(:,:,4) = opticflow;
    
    label_all = double(imread([path_in_label '\' num2str(i) '.bmp']));
    label_all = label_all./255;
    label_all = repmat(label_all,[1 1 4]);
    
    for m = 1:14:337
        for n = 1:14:337
            sample = sample_all(m:m+111, n:n+111,:);
            label = label_all(m:m+111, n:n+111,:);       
            k = k+1;
            save([path_out '\' num2str(k) '.mat'], 'sample', 'label', '-v7.3');     
        end
    end
end