clc;
clear;

path_input = 'F:\zhangyuhan\GA_tmp\rnn_results';
path_output = 'F:\zhangyuhan\GA_tmp\combined results';

img = zeros(448, 448, 3);
for  k = 1:448
    
    load([path_input '\' 'results' '\'  num2str(k) '.mat']);
    scoremap = double(scoremap);
    scoremap = squeeze(scoremap(:,2));
    img(k,:,1) = scoremap;
    
    load([path_input '\' 'results1' '\' num2str(k) '.mat']);
    scoremap1 = double(scoremap1);
    scoremap1 = squeeze(scoremap1(:,2));
    img(k,:,2) = scoremap1;
    
    load([path_input '\' 'results2' '\' num2str(k) '.mat']);
    scoremap2 = double(scoremap2);
    scoremap2 = squeeze(scoremap2(:,2));
    img(k,:,3) = scoremap2;
end
imwrite(uint8(img.*255),[path_output '\' '1.bmp']);