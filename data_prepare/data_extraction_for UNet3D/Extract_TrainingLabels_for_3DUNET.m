function Extract_TrainingLabels_for_3DUNET()

clc;
clear;
close all;

path_in_proj = 'GA_Proj';
path_in_bscan = 'GA_register';

path_out = 'labels_for_3DUNET';

if ~exist(path_out,'dir')
    mkdir(path_out);
end

patient_num = 38;

k = 0;
for i =1:patient_num
    
    if ~exist([path_in_bscan '\' num2str(i)], 'dir')
        continue;
    end
%     
%     if i == 21
%         continue;
%     end
    
    [name_pre, timelist, name_post] = SortTime(path_in_proj, num2str(i));
    
    for j = 1:1
        k = k+1;
        disp([num2str(i) '  ' num2str(j)]);
           
        cube_name3 = [name_pre ' ' num2str(timelist(j+2)) ' ' name_post];
        
        labels= ReadImage([path_in_proj '\' num2str(i)], cube_name3);
        imwrite(uint8(labels.*255),[path_out '\' num2str(k) '.bmp']);   
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
function gt = ReadImage(path_gt, cube_name3)

if ~exist([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp'],'file')
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'BW.bmp']));
else
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp']));
end
gt = im2bw(gt);
gt = double(gt);
gt = gt(33:480,33:480);

end