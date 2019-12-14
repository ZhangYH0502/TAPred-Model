function Extract_TrainingSamples()

clc;
clear;
close all;

path_in_proj = 'GA_Proj';
path_in_bscan = 'GA_register';

path_out = 'samples';

if ~exist(path_out, 'dir')
    mkdir(path_out);
end

patient_num = 38;
batch_size = 8;
sample_len = 1000;

k = 0;
for i = 1:patient_num
    
    if ~exist([path_in_bscan '\' num2str(i)], 'dir')
        continue;
    end
    
%     if i == 21
%         continue;
%     end
    
    [name_pre, timelist, name_post] = SortTime(path_in_proj, num2str(i));
    
    for j = 1:1
        disp([num2str(i) '  ' num2str(j)]);
        cube_name1 = [name_pre ' ' num2str(timelist(j)) ' ' name_post];
        cube_name2 = [name_pre ' ' num2str(timelist(j+1)) ' ' name_post];
        cube_name3 = [name_pre ' ' num2str(timelist(j+2)) ' ' name_post];
        
        [time_interval1, time_interval2] = time_interval(num2str(timelist(j)), num2str(timelist(j+1)), num2str(timelist(j+2)));
        
        [VoxelData1, VoxelData2, gt]= ReadImage([path_in_bscan '\' num2str(i)], [path_in_proj '\' num2str(i)], cube_name1, cube_name2, cube_name3);
        
        VoxelData1_new = zeros(size(VoxelData1,1)+batch_size*2, size(VoxelData1,2)+batch_size*2, size(VoxelData1,3));
        VoxelData1_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData1;
        VoxelData2_new = zeros(size(VoxelData2,1)+batch_size*2, size(VoxelData2,2)+batch_size*2, size(VoxelData2,3));
        VoxelData2_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData2;
        gt_new = ones(size(gt,1)+batch_size*2, size(gt,2)+batch_size*2);
        gt_new = gt_new.*2;
        gt_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size) = gt;
        
        sum1 = sum(VoxelData1_new,3);
        sum1 = sum1 == 0;
        sum2 = sum(VoxelData2_new,3);
        sum2 = sum2 == 0;
        sum3 = sum1 | sum2;
        gt_new(sum3) = 2;
        %         figure;imshow(gt_new, []);
        
        [r1, c1] = find(gt_new == 1);
        randnum = randperm(length(r1));
        r1 = r1(randnum);
        c1 = c1(randnum);
        r1 = r1(1:sample_len);
        c1 = c1(1:sample_len);
        
        for m = 1:sample_len
            r = r1(m);
            c = c1(m);
            sample1 = VoxelData1_new(r-batch_size:r+batch_size, c-batch_size:c+batch_size, :);
            sample1 = reshape(sample1, [(batch_size*2+1)*(batch_size*2+1) size(sample1,3)]);
            sample2 = VoxelData2_new(r-batch_size:r+batch_size, c-batch_size:c+batch_size, :);
            sample2 = reshape(sample2, [(batch_size*2+1)*(batch_size*2+1) size(sample2,3)]);
            sample2 = flip(sample2,1);
            sample = [sample1 ; sample2];
            label = [0 1];
            k = k+1;
            save([path_out '\' num2str(k) '.mat'], 'sample', 'label', 'time_interval1', 'time_interval2', '-v7.3');
        end
        
        [r2, c2] = find(gt_new == 0);
        randnum = randperm(length(r2));
        r2 = r2(randnum);
        c2 = c2(randnum);
        r2 = r2(1:sample_len);
        c2 = c2(1:sample_len);
        
        for m = 1:sample_len
            r = r2(m);
            c = c2(m);
            sample1 = VoxelData1_new(r-batch_size:r+batch_size, c-batch_size:c+batch_size, :);
            sample1 = reshape(sample1, [(batch_size*2+1)*(batch_size*2+1) size(sample1,3)]);
            sample2 = VoxelData2_new(r-batch_size:r+batch_size, c-batch_size:c+batch_size, :);
            sample2 = reshape(sample2, [(batch_size*2+1)*(batch_size*2+1) size(sample2,3)]);
            sample2 = flip(sample2,1);
            sample = [sample1 ; sample2];
            label = [1 0];
            k = k+1;
            save([path_out '\' num2str(k) '.mat'], 'sample', 'label', 'time_interval1', 'time_interval2', '-v7.3');
        end
    end
end
end

%%
function [name_pre, timelist, name_post] = SortTime(path, patient_name)

cube_list = dir([path '\' patient_name]);
cube_list(1:2) = [];
timelist = zeros(1,length(cube_list));
for j = 1:length(cube_list)
    cube_name = cube_list(j).name;
    cube_name_split = strsplit(cube_name);
    timename = cube_name_split{2};
    timelist(1,j) = str2double(timename);
end
timelist = sort(timelist);
name_pre = cube_name_split{1};
name_post = cube_name_split{3};

end

%%
function [time_interval1, time_interval2] = time_interval(time1, time2, time3)

time1_year = str2num(time1(1:4));
time1_month = str2num(time1(5:6));
time2_year = str2num(time2(1:4));
time2_month = str2num(time2(5:6));
time3_year = str2num(time3(1:4));
time3_month = str2num(time3(5:6));

time_interval1 = (time2_year-time1_year)*12+(time2_month-time1_month);
time_interval2 = (time3_year-time2_year)*12+(time3_month-time2_month);

end

%%
function [VoxelData1, VoxelData2, gt] = ReadImage(path_bscan, path_gt, cube_name1, cube_name2, cube_name3)

VoxelData1 = zeros(224, 448, 448);
VoxelData2 = zeros(224, 448, 448);
for k = 1:448
    VoxelData1(:,:,k) = double(imread([path_bscan '\' cube_name1 '\' num2str(k) '.bmp']));
    VoxelData2(:,:,k) = double(imread([path_bscan '\' cube_name2 '\' num2str(k) '.bmp']));
end
VoxelData1 = permute(VoxelData1,[3,2,1]);
VoxelData2 = permute(VoxelData2,[3,2,1]);

if ~exist([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp'],'file')
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'BW.bmp']));
else
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp']));
end
gt = im2bw(gt);
gt = double(gt);
gt = gt(33:480,33:480);

end