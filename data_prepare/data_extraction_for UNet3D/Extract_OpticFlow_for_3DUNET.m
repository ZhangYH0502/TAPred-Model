function Extract_OpticFlow_for_3DUNET()

clc;
clear;
close all;

path_in_proj = 'GA_Proj';
path_in_bscan = 'GA_register';

path_out = 'opticflow_for_3DUNET';
mkdir(path_out);

patient_num = 38;

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
        k = k+1;
        disp([num2str(i) '  ' num2str(j)]);
           
        cube_name1 = [name_pre ' ' num2str(timelist(j)) ' ' name_post];
        cube_name2 = [name_pre ' ' num2str(timelist(j+1)) ' ' name_post];
        
        [time_interval1, time_interval2] = time_interval(num2str(timelist(j)), num2str(timelist(j+1)), num2str(timelist(j+2)));
        
        labels1= ReadImage([path_in_proj '\' num2str(i)], cube_name1);
        labels2= ReadImage([path_in_proj '\' num2str(i)], cube_name2);
        
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
        
        imwrite(uint8(labels.*80),[path_out '\' num2str(k) '.bmp']);   
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
function gt = ReadImage(path_gt, cube_name3)

if ~exist([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp'],'file')
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'BW.bmp']));
else
    gt = double(imread([path_gt '\' cube_name3 '\' cube_name3 'Registeredbw.bmp']));
end
gt = im2bw(gt);
gt = gt(33:480,33:480);

end