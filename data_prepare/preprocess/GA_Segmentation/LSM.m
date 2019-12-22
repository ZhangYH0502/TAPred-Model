function seg = LSM(Img,mask)
epsilon = 0.05;
if round(sum(mask(:)))>400 % 0.1*
    num_it = 600;
else
    num_it = 200;%200
end
rad = 3;
alpha = 0.03;% coefficient of the length term
mask_init  = double(mask);
mask_init(mask(:)==1) = 1;

seg = global_AC_UM(Img,mask_init,rad,alpha,num_it,epsilon);
