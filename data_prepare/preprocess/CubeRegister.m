clc;
clear;
close all;

path_in_proj = 'GA_Proj';
path_in_bscan = 'GA_flatten';
path_out_bscan = 'GA_register';

for i = 1:38
    cube_list = dir([path_in_proj '\' num2str(i)]);
    for j = 3:length(cube_list)
        cube_name = cube_list(j).name;
        
        disp([num2str(i) '  ' cube_name]);
         
        % 读128帧BSCAN
        A = zeros(448, 512, 128);
        for k = 1:128
            A(:,:,k) = double(imread([path_in_bscan '\' num2str(i) '\' cube_name  '\' num2str(k) '.bmp']));
        end
        A = reshape3Dmatrix(A);
        A = A(1:2:end,:,:);
        
        % 文件夹中如有配准矩阵，则配准
        if exist([path_in_proj '\' num2str(i) '\' cube_name '\' cube_name 't_fundus.mat'], 'file')
            load([path_in_proj '\' num2str(i) '\' cube_name '\' cube_name 't_fundus.mat']);
            [A,~,~]= imtransform(permute(A, [3 2 1]), t_fundus, 'XData',[1 512], 'YData',[1 512]);
            A = permute(A, [3 2 1]);
        end
        
        A = A(:,33:480,33:480);
        
        % 保存bmp格式
        mkdir([path_out_bscan '\' num2str(i) '\' cube_name]);
        for k = 1:448
            imwrite(uint8(A(:,:,k)), [path_out_bscan '\' num2str(i) '\' cube_name '\' num2str(k) '.bmp']);
        end
    end
end
