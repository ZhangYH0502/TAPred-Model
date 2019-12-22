PATH = 'F:\8-12\NewExpData';
dir1 = dir([PATH '\P*']);
for num=1:length(dir1)
    
    dir2 = dir([PATH '\' dir1(num).name '\P*.tif']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
    
    dir2 = dir([PATH '\' dir1(num).name '\P*Fusionbw.bmp']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
    
    dir2 = dir([PATH '\' dir1(num).name '\P*FusionImg.bmp']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
    
    dir2 = dir([PATH '\' dir1(num).name '\P*Registeredbw.bmp']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
    
    dir2 = dir([PATH '\' dir1(num).name '\P*RegisteredImg.bmp']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
    
    dir2 = dir([PATH '\' dir1(num).name '\P*t_fundus.mat']);
    if length(dir2)>0
        delete([PATH '\' dir1(num).name '\' dir2(1).name]);
    end
end