% Auther: Jian Chen
% April 2008
% Department of Biomedical imaging, Columbia University, New York, USA
% Institute of Automation, Chinese Academy of Sciences, Beijing, China
% email: jc3129@columbia.edu,  jian.chen@ia.ac.cn
% All rights reserved


function rr_showmatch(I1_p,I2_p,loc1,loc2,s);

I1 = I1_p(s+1:end-s,s+1:end-s);
I2 = I2_p(s+1:end-s,s+1:end-s);
loc1 = loc1-s;
loc2 = loc2-s;

im3 = rr_appendimages(I1,I2);

figure,imshow(im3,[])
title('matched corner points');
hold on
cols = size(I1,2);

for i=1:size(loc1,1)
    line([loc1(i,1) loc2(i,1)+cols],[loc1(i,2) loc2(i,2)], 'Color', 'r');
    plot(loc1(i,1),loc1(i,2),'g+')
    plot(loc1(i,1),loc1(i,2),'go')
    plot(loc2(i,1)+cols,loc2(i,2),'g+')
    plot(loc2(i,1)+cols,loc2(i,2),'go')
end