% Auther: Jian Chen
% April 2008
% Department of Biomedical imaging, Columbia University, New York, USA
% Institute of Automation, Chinese Academy of Sciences, Beijing, China
% email: jc3129@columbia.edu,  jian.chen@ia.ac.cn
% All rights reserved

function im = appendimages(image1, image2)

rows1 = size(image1,1);
rows2 = size(image2,1);

if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end

im = [image1 image2];   
