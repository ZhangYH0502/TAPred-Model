function seg = LSM1(Img,mask)
epsilon = 0.05;
if round(0.1*sum(mask(:)))>1000
    num_it = 100;
else
    num_it = 100;%round(0.1*sum(mask(:)));
end
rad = 3;
alpha = 0.03;% coefficient of the length term
mask_init  = double(mask);
mask_init(mask(:)==1) = 1;
% mask_init(mask(:)==0) = 0;
% seg = local_AC_UM(Img,mask_init,rad,alpha,num_it,epsilon);
seg = global_AC_UM(Img,mask_init,rad,alpha,num_it,epsilon);
