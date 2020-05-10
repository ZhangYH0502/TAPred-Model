function Extract_TestingSamples_for_rnn()

clc;
clear;
close all;

path_in_proj = 'F:\zhangyuhan\GA_tmp\pre-processing\GA_mask_register';
path_in_bscan = 'F:\zhangyuhan\GA_tmp\GA_register';

path_out = 'F:\zhangyuhan\GA_tmp\testing_for_rnn';
path_out_op = 'F:\zhangyuhan\GA_tmp\opticflow';

if ~exist(path_out, 'dir')
    mkdir(path_out);
end

batch_size = 8;

%testing 2 cube names
cube_name1 = 'A_Macular Cube 512x128_6-15-2016_9-39-33_O_s_cube_z';
cube_name2 = 'A_Macular Cube 512x128_10-28-2016_11-14-28_O_s_cube_z';
%setting time interval
time_interval1 = 4+5;
time_interval2 = 5;

[VoxelData1, VoxelData2, gt1, gt2]= ReadImage(path_in_bscan, path_in_proj, cube_name1, cube_name2);

growth_map = opticflow_gen(gt1, gt2, time_interval1, time_interval2);
imwrite(uint8(growth_map),[path_out_op '\' '1.bmp']);

VoxelData1_new = zeros(size(VoxelData1,1)+batch_size*2, size(VoxelData1,2)+batch_size*2, size(VoxelData1,3));
VoxelData1_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData1;
VoxelData2_new = zeros(size(VoxelData2,1)+batch_size*2, size(VoxelData2,2)+batch_size*2, size(VoxelData2,3));
VoxelData2_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData2;

for m = batch_size+1:batch_size+448
    sample = zeros(448, 578, 224);
    k = 0;
    for n = batch_size+1:batch_size+448
        sample1 = VoxelData1_new(m-batch_size:m+batch_size, n-batch_size:n+batch_size, :);
        sample1 = reshape(sample1, [(batch_size*2+1)*(batch_size*2+1) size(sample1,3)]);
        sample2 = VoxelData2_new(m-batch_size:m+batch_size, n-batch_size:n+batch_size, :);
        sample2 = reshape(sample2, [(batch_size*2+1)*(batch_size*2+1) size(sample2,3)]);
        sample2 = flip(sample2,1);
        k = k+1;
        sample(k,:,:) = [sample1 ; sample2];
    end
    save([path_out '\'  num2str(m-batch_size) '.mat'], 'sample', 'time_interval1', 'time_interval2','-v7.3');
end
end

%%
function [VoxelData1, VoxelData2, gt1, gt2] = ReadImage(path_bscan, path_gt, cube_name1, cube_name2)

VoxelData1 = zeros(224, 448, 448);
VoxelData2 = zeros(224, 448, 448);
for k = 1:448
    VoxelData1(:,:,k) = double(imread([path_bscan '\' cube_name1 '\' num2str(k) '.bmp']));
    VoxelData2(:,:,k) = double(imread([path_bscan '\' cube_name2 '\' num2str(k) '.bmp']));
end
VoxelData1 = permute(VoxelData1,[3,2,1]);
VoxelData2 = permute(VoxelData2,[3,2,1]);

gt1 = double(imread([path_gt '\' cube_name1 '.bmp']));
gt1 = im2bw(gt1);

gt2 = double(imread([path_gt '\' cube_name2 '.bmp']));
gt2 = im2bw(gt2);
end

%%
function growth_map = opticflow_gen(labels1, labels2, time_interval1, time_interval2)

sum1 = sum(labels1(:));
sum2 = sum(labels2(:));

th = time_interval2/time_interval1;

labels_t = labels2;
sum_t = sum(labels_t(:));

while abs(sum_t-sum2)/abs(sum2-sum1) < th
    labels_t = imdilate(labels_t,strel('disk',1));
    sum_t = sum(labels_t(:));
end

labels = double(labels1)+double(labels2)+double(labels_t);
growth_map = labels.*80;
end