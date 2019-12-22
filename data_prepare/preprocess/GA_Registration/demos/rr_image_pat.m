% Auther: Sijie Niu
% Jan 2015
% Radiology Department, Stanford University, CA, USA
% Computer Science and Engineering, Nanjing Univerisyt of Science and Technology, Nanjing, China
% email: sjniu@hotmail.com
% All rights reserved

function [I1_p, I2_p] = rr_image_pat(I1,I2,s);

if nargin == 3
    
[m1,n1] = size(I1);
[m2,n2] = size(I2);

I1_p = zeros([m1+2*s,n1+2*s]);
I2_p = zeros([m2+2*s,n2+2*s]);

I1_p(s+1:end-s,s+1:end-s) = I1;
I2_p(s+1:end-s,s+1:end-s) = I2;

end

if nargin == 2
    s = I2;   
    [m1,n1] = size(I1);
    I1_p = zeros([m1+2*s,n1+2*s]);
    I1_p(s+1:end-s,s+1:end-s) = I1;
    I2_p = [];
end
    