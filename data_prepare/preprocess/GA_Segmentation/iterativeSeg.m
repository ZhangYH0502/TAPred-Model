function [BW2 lev] = iterativeSeg(BW,GA_BM_Ori)

tmp1 = GA_BM_Ori(BW(:)==1);%foreground
tmp2 = GA_BM_Ori(BW(:)==0);%background

L1 = mean(tmp1);% the mean value of foreground
L2 = mean(tmp2);% the mean value of background
bw1 = (tmp1>L1);% binarary 
bw2 = (tmp2<L2); % binarary 

BW1 = zeros(size(GA_BM_Ori));
BW2 = zeros(size(GA_BM_Ori));

BW2(BW(:)==1) = bw1; % TEMPERATY SAVE FOREGROUND

BW1(BW(:)==1) = bw1;
BW1(BW(:)==0) = bw2;

tmp = GA_BM_Ori(BW1(:)==0); % 

lev = graythresh(tmp);
BW11 = im2bw(tmp,lev) ;

BW2(BW1(:)==0)=BW11;

end