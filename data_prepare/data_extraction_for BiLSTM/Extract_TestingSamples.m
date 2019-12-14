function Extract_TestingSamples()

% clc;
clear;
close all;

path_in_proj = 'GA_Proj';
path_in_bscan = 'GA_register';

path_out = 'testing';

patient_num = 38;
batch_size = 8;

for i = 1:patient_num
    
    if ~exist([path_in_bscan '\' num2str(i)], 'dir')
        continue;
    end
    
    [name_pre, timelist, name_post] = SortTime(path_in_proj, num2str(i));
    
    if length(timelist) == 3
        continue;
    end
    
    if ~exist([path_out '\' num2str(i)], 'dir')
        mkdir([path_out '\' num2str(i)]);
    end
    
    v = 0;
    for j = 2:length(timelist)-2
        
        disp(num2str(i));
        cube_name1 = [name_pre ' ' num2str(timelist(j)) ' ' name_post];
        cube_name2 = [name_pre ' ' num2str(timelist(j+1)) ' ' name_post];
        cube_name3 = [name_pre ' ' num2str(timelist(j+2)) ' ' name_post];
        
        [time_interval1, time_interval2] = time_interval(num2str(timelist(length(timelist)-2)), num2str(timelist(length(timelist)-1)), num2str(timelist(length(timelist))));
        
        [VoxelData1, VoxelData2, ~]= ReadImage([path_in_bscan '\' num2str(i)], [path_in_proj '\' num2str(i)], cube_name1, cube_name2, cube_name3);
        
        VoxelData1_new = zeros(size(VoxelData1,1)+batch_size*2, size(VoxelData1,2)+batch_size*2, size(VoxelData1,3));
        VoxelData1_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData1;
        VoxelData2_new = zeros(size(VoxelData2,1)+batch_size*2, size(VoxelData2,2)+batch_size*2, size(VoxelData2,3));
        VoxelData2_new(batch_size+1:end-batch_size, batch_size+1:end-batch_size, :) = VoxelData2;
        
        v = v+1;
        mkdir([path_out '\' num2str(i) '\' num2str(v)]);
        
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
            save([path_out '\' num2str(i) '\' num2str(v) '\' num2str(m-batch_size) '.mat'], 'sample', 'time_interval1', 'time_interval2','-v7.3');
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