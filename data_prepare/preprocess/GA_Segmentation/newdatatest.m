dir1 = dir(['J:\newGA1\' '*.mat']);
for num=15:length(dir1)
    load(['J:\newGA1\' dir1(num).name],'RPE_Dw_Im','I_noise');
    [BW]=BScan_GAseg(RPE_Dw_Im,I_noise);
    imwrite(BW,['res/' dir1(num).name(1:end-4) '.bmp']);
end