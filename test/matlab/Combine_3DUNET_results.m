clc;
clear all;

path_in  = 'F:\zhangyuhan\GA_tmp\3DUNet-results';
path_out = 'F:\zhangyuhan\GA_tmp\final-results';

sample = zeros(448,448,4);

k = 0;
for m = 1:112:337
    for n = 1:112:337
        k = k+1;
        load([path_in '\' num2str(k) '.mat']);
        pred = double(pred);
        pred = permute(pred, [2 3 1]);
        sample(m:m+111,n:n+111,:) = pred;
    end
end

sample = squeeze(sum(sample,3));
sample = sample>2;

sample=double(sample).*255;

imwrite(uint8(sample),[path_out '\' '1.bmp']);