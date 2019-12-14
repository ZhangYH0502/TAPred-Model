clc;
clear;

path_in_bscan = '';
path_in_layer = '';
path_out = '';

patient_num = 22;
for i = 1:patient_num
    cube_list = dir([path_in_bscan '\' num2str(i)]);
    cube_list(1:2) = [];  
    for j = 1:length(cube_list)
        disp([num2str(i) '---' num2str(j)]);
        cube_name = cube_list(j).name;
        mkdir([path_out '\' num2str(i) '\' cube_name]);
        load([path_in_layer '\' cube_name '.mat']);
        for s = 1:128
            img = double(imread([path_in_bscan '\' cube_name '.mat' '\' num2str(s) '.bmp']));
            rpe_r = IO_Up_Im(:,s);
            new_cube = zeros(448, 512);
            for c = 1:512
                if rpe_r(c)-178 < 1
                    new_cube(:,c) = img(1:448,c);
                else
                    if rpe_r(c)+269 > 1024
                        new_cube(:,c) = img(1024-448+1:1024,c);
                    else                     
                        new_cube(:,c) = img(rpe_r(c)-178:rpe_r(c)+269,c);
                    end
                end
            end
            imwrite(uint8(new_cube), [path_out '\' num2str(i) '\' cube_name '\' num2str(s) '.bmp']);
        end
    end
end