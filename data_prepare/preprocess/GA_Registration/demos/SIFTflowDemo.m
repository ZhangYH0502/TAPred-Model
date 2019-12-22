% load the imahes
% im1=imread('Mars1HalfSize.png');
% im2=imread('Mars2HalfSize.png');
PATH = 'G:\8-12\NewExpData';
dir1 = dir([PATH '\P*']);
for num=1:length(dir1)
    im1 = imread([PATH '\' dir1(num).name '\' dir1(num).name 'VESSEL_Proj.bmp']);
    bwim1 = logical(imread([PATH '\' dir1(num).name '\' dir1(num).name 'BW.bmp']));
    RSVP1 = imread([PATH '\' dir1(num).name '\' dir1(num).name 'GA_Proj.bmp']);
    space_ind = strfind(dir1(num).name, ' ');
    dir2 = dir([PATH '\' dir1(num).name(1:(space_ind(1)-1)) '*' dir1(num).name((space_ind(2)+1):length(dir1(num).name))]);
    for loc=1:length(dir2)
        if strcmp(dir1(num).name,dir2(loc).name)
            next_num = loc;
            break;
        end
    end
    if (next_num+1)>length(dir2)
        continue;
    end
    im2 = imread([PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'VESSEL_Proj.bmp']);
    bwim2 = logical(imread([PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'BW.bmp']));
    RSVP2 = imread([PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'GA_Proj.bmp']);
% im1=imread('85.bmp');
% im2=imread('86.bmp');
% bwim1 = imread('2bw.bmp');
% bwim2 = imread('3bw.bmp');

% Compute SIFT images
patchsize=8; %half of the window size for computing SIFT
gridspacing=1; %sampling step (use 1 for registration)

% im1 = double(im1)/255;
% im2 = double(im2)/255;
% im1 = bfilter2_aniso(im1,[3 7],[0.5 0.1]);
% im2 = bfilter2_aniso(im2,[3 7],[0.5 0.1]);
[im1, im2] = rr_image_pat(im1,im2,4);
[bwim1, bwim2] = rr_image_pat(bwim1,bwim2,4);
[RSVP1,RSVP2] = rr_image_pat(RSVP1,RSVP2,4);

% compute dense SIFT images
Sift1=iat_dense_sift(im2double(im1),patchsize,gridspacing);
Sift2=iat_dense_sift(im2double(im2),patchsize,gridspacing);

% visualize SIFT image
% figure;imshow(iat_sift2rgb(Sift1));title('SIFT image 1');
% figure;imshow(iat_sift2rgb(Sift2));title('SIFT image 2');


% SIFT-flow parameters
SIFTflowpara.alpha=1;%1
SIFTflowpara.d=20;%40
SIFTflowpara.gamma=0.001;%0.005
SIFTflowpara.nlevels=8;%4
SIFTflowpara.wsize=5;%5
SIFTflowpara.topwsize=20;%20
SIFTflowpara.nIterations=60;%60

% Run the algorithm
vx=[];vy=[];
tic;[vx,vy,energylist]=iat_SIFTflow(Sift1,Sift2,SIFTflowpara);toc


% VISUALIZE RESULTS

% Keep the pixels that are present in SIFT images 
if gridspacing==1
    Im1=im1(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    Im2=im2(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    bwIm1=bwim1(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    bwIm2=bwim2(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    RSVP1=RSVP1(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    RSVP2=RSVP2(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
else
  im1filt=imfilter(im1,fspecial('gaussian',7,1.),'same','replicate');
  Im1 = im1filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
  im2filt=imfilter(im2,fspecial('gaussian',7,1.),'same','replicate');
  Im2 = im2filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
end

% warp the image (inverse warping of Im2)
[rim, cim, zim]=size(Im2);
[xx,yy]=meshgrid(1:cim,1:rim);
XX = xx;
YY = yy;

% Adding displacements to pixels
XX=XX+vx;
YY=YY+vy;
support=XX<1 | XX>cim | YY<1 | YY>rim;
ind = find(support(:)==1);
XX1 = XX;YY1 = YY;xx1 = xx;yy1=yy;
XX1(ind)=[];YY1(ind)=[];xx1(ind)=[];yy1(ind)=[];

loc1 = [XX1(:),YY1(:)];
loc2 = [xx1(:),yy1(:)];
t_fundus = cp2tform(loc1(:,1:2),loc2(:,1:2),'affine'); 
I1_c = imtransform(Im2,t_fundus,'XData',[1 size(Im2,2)], 'YData',[1 size(Im2,1)]);
I1_bw = imtransform(bwIm2,t_fundus,'XData',[1 size(bwIm2,2)], 'YData',[1 size(bwIm2,1)]);
RSVP2_reg = imtransform(RSVP2,t_fundus,'XData',[1 size(RSVP2,2)], 'YData',[1 size(RSVP2,1)]);


subplot(2,4,1);imshow(Im1,[]);title('Reference Image');
subplot(2,4,2);imshow(Im2,[]);title('moving Img');
subplot(2,4,3);imshow(I1_c,[]);title('Registered Img');
subplot(2,4,4);imshow(double(I1_c)+double(Im1),[]);title('fusion Img');
subplot(2,4,5);imshow(bwIm1);title('Ref binary Img');
subplot(2,4,6);imshow(bwIm2);title('Moving binary Img');
subplot(2,4,7);imshow(I1_bw-bwIm1,[]);title('fusion binary Img');
saveas(gcf,[ PATH '\' dir1(num).name '\' dir1(num).name '.tif']);
I1_c = (I1_c-min(I1_c(:)))/(max(I1_c(:))-min(I1_c(:)));
Im1 = (Im1-min(Im1(:)))/(max(Im1(:))-min(Im1(:)));
fusionImg = (double(I1_c)+double(Im1));
fusionImg = (fusionImg-min(fusionImg(:)))/(max(fusionImg(:))-min(fusionImg(:)));
I1_bw(I1_bw(:)>0)=1;
fusion_bw = I1_bw-bwIm1;
fusion_bw((fusion_bw(:)>0))=1;
fusion_bw(find(abs(fusion_bw(:))==0))=0.5;
fusion_bw(fusion_bw(:)==-1)=0;

RSVP2_reg = (RSVP2_reg-min(RSVP2_reg(:)))/(max(RSVP2_reg(:))-min(RSVP2_reg(:)));
imwrite((RSVP2_reg),[PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'RegisteredGA_Proj.bmp']);
imwrite((I1_c),[PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'RegisteredImg.bmp']);
imwrite(fusionImg,[PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'FusionImg.bmp']);
imwrite(fusion_bw,[PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'Fusionbw.bmp']);
imwrite(I1_bw,[PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 'Registeredbw.bmp']);
save([PATH '\' dir2(next_num+1).name '\' dir2(next_num+1).name 't_fundus.mat'],'t_fundus');
end
% 
% [bwwarpI2,warpI2, support] = iat_pixel_warping(Im2,vx,vy,bwIm2);
% 
% figure;imshow(Im1);title('Image 1');
% figure;imshow(uint8(warpI2));title('Warped Image 2');
% 
% figure;imshow(bwwarpI2);
% figure;imshow(bwIm1);
% 
% bwI = bwwarpI2-bwIm1;
% figure;imshow(bwI,[])
% figure;
% subplot(2,2,1);imshow(bwIm1);title('reference image');
% subplot(2,2,2);imshow(bwIm2);title('moving image');
% subplot(2,2,3);imshow(bwwarpI2);title('after transformation');
% subplot(2,2,4);imshow(bwI,[]);title('the difference between the registered image and reference image');
% saveas(gcf,'8-9.tif');
% % visualize alignment error
% [~, grayerror] = iat_error2gray(Im1,warpI2,support);
% figure;imshow(grayerror);title('Registration error');
% 
% % display flow
% figure;imshow(iat_flow2rgb(vx,vy));title('SIFT flow field');

