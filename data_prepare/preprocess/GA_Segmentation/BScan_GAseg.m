function  [BW]=BScan_GAseg(RPE_Dw_Im,I_noise)
% PATH = 'G:\Doctor\GA segmentation\GAdata';
% PATH1 = 'G:\Doctor\OriImg\GA images\ALLGADATA\';
% dir1 = dir([PATH '\*.mat']);
% for jj=5:5%length(dir1)
% load([PATH '\' dir1(jj).name]);BM = RPE_Dw_Im;
% load(['J:\newGA\P1264201 20090127 OS\' dir1(jj).name],'RPE_Up_Im','RPE_Dw_Im');
% load ('L:\sf\P20140121152813578 20130520 OS\Segmentation_results_HR.mat',...
%    'I_noise','ILM_Im','RPE_Dw_Im','RPE_Up_Im','IO_Up_Im','IO_Dw_Im','NFL_Up_Im','OPL_Dw_Im','INL_Dw_Im','IPL_Dw_Im','macula_mask','BV_mask');
%P20101028173518406 20100310 OS;P20101028173518406 20080930
%OD;P20140130121208437 20081215 OS;P20140130121208437
%20100813;P20140206103333125 20080325 OS;P20140206103333125 20110214
%OD;P20140206103333125 20110214 OS;P20140219132040390 20110519 OS;P20140219132040390 20080603 OS
%OD;P20140205152620078 20080513 OD;P20140121152813578 20120119
%OS;P20140206103333125 20080325 OD;P20140224125437375 20101208 OD;P20140224125437375 20131112 OD
% [I_noise,PathName,FileName] = Open3Dimg(PATH1,[dir1(jj).name(1:end-4) '.img']);
[row col dim] = size(I_noise);

[X,Y] = meshgrid(1:(col/dim):col,1:col);
[Xh,Yh] = meshgrid(1:col,1:col);
B_scan_dis=1000;

RPE_Dw_Im=round(gridfit(X(:), Y(:), RPE_Dw_Im(:),[1:(col/dim):col], Y(1:col), 'smoothness',[(dim/0.001)*(1/(B_scan_dis)),col/(0.001)],'regularizer', 'diffusion' ));
BM = RPE_Dw_Im';


d_BM = min(230,row - max(BM(:)+20) - 1); %maximun projection distance from BM
start_loc1 = BM+20;
end_loc1 = start_loc1+d_BM;

GA = [];
GA_BM_Ori=[];
for num=1:dim
    
    Ai = (double(I_noise(:,:,num))/255); %denoised image
    tmp = [];
	for j=1:col
        tmp(:,j) = Ai(start_loc1(num,j):end_loc1(num,j),j);
        GA_BM_Ori(num,j) = mean(Ai(start_loc1(num,j):end_loc1(num,j),j));
    end    
    fliterprojectimg=moving_filter(GA_BM_Ori(num,:));
    GA(num,:)=fliterprojectimg;
end

% figure(11);bb = max(GA);plot(bb);hold on; plot((1:512),mean(bb(5:end)-std(bb(5:end))),'r');
bb=max(GA);

%%
if min(bb(5:end))>0.35
    level = min(bb(5:end))-std(bb(5:end));
else
    level = min(bb(5:end))+1.5*std(bb(5:end));
end

lev = graythresh(GA_BM_Ori);
if lev > level
    level = lev;
end

BW = im2bw(GA_BM_Ori,level);

GA_BM_O = GA_BM_Ori;

GA_BM_Ori = bfilter2(GA_BM_Ori,5,[0.5,0.1]);
GA_BM_Ori = normalized(GA_BM_Ori);
minth = 0.05;%0.02  0.05
th0= 0;
k=2;

% GA = imresize(GA,[256 256]);
% GA = normalized(GA);

% [BW th] = iterativeSeg(BW,GA_BM_Ori);
% BW1 = BW;
% while abs(th0-th)>minth
%     BW = BW1;
%     disp(k);
%     th0 = th;
%     [BW1 th] = iterativeSeg(BW,GA_BM_Ori);
%     
%     k=k+1;
% end

% for i=1:dim
%     tmpBW = BW(i,:);
%     BW(i,:)= bwareaopen(tmpBW,3);
% end

BW= bwareaopen(BW,round(10/(512*128)*dim*col),4);%50

%%
BW = imresize(logical(BW),[col col]);
GA_BM_Ori = imresize(GA_BM_Ori,[col col]);
GA_BM_Ori = normalized(GA_BM_Ori);
GA_BM_O = imresize(GA_BM_O,[col col]);
GA_BM_O = normalized(GA_BM_O);
% if col==512
BW = PostProcessing2(BW,GA_BM_O);
% end

BW = imresize(logical(BW),[dim col]);

%%
dis = bb-mean(bb(5:end))+std(bb(5:end));
dis = double(dis>0);
dis = 1-bwareaopen(1-dis,20);
inx1 = (round(0.1172*col):round(0.8789*col));
iny = (round(10/128*dim):round(95/128*dim));

% inx1 = (60:450);
% iny = (10:95);
for j=iny
    tmp = zeros([1 col]);
    INDX = [];
    tmp(inx1) = BW(j,inx1);
    INDX = find(tmp);
    if length(INDX)>0
        inx = INDX(1):INDX(length(INDX));
    tmp(inx) = BW(j,inx);
    tmp1 = tmp;
    tmp = 1-bwareaopen(1-tmp,120);%%120 80
    tmp11 = tmp-tmp1;
    tmp11 = bwareaopen(tmp11,2);
    tmp12 = tmp1+tmp11;
    tmp(inx) = tmp12(inx);
    res = double(logical(tmp) & logical(dis));
    BW(j,inx) = double(logical(res(inx)) | logical(BW(j,inx)));
    end
end

%% downsample
% col=512;
BW = logical(BW);
BW = imresize(BW,[col/2 col/2]);

GA_BM_Ori = imresize(GA_BM_Ori,[col/2 col/2]);
GA_BM_Ori = normalized(GA_BM_Ori);
tic
res = LSM(GA_BM_Ori,BW);
toc

res = logical(bwareaopen(double(res),round(100/(256)^2*(col/2)^2)));

BW = imresize(res,[col col]);
% imtool(BW);
BW=fillsmallholes((BW),round(350/(512*512)*col*col));

GA_BM_Ori = imresize(GA_BM_Ori,[col col]);
GA_BM_Ori = normalized(GA_BM_Ori);
% if col==512
BW = PostProcessing1(BW,GA_BM_O);
% end
if col==512 
    r=5;
else
    r=2;
end
se = strel ('disk',r);%512*512 5;200*200 2
BW = imdilate(BW,se);

BW = bwareaopen(BW,round(200/(512*512)*col*col),4);
res = LSM1(GA_BM_Ori,BW);
BW=fillsmallholes((BW),round(500/(512*512)*col*col));

% imwrite(BW,['midres2/' dir1(jj).name(1:end-4) '.bmp']);

end