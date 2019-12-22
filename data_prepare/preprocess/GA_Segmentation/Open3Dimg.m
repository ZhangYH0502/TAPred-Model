function [A,PathName,FileName] = Open3Dimg(PathName,FileName)
%open 3D .img oct retinal images

% [FileName,PathName] = uigetfile('*.img');
fid = fopen(strcat(PathName,FileName),'r');

pixeldim = [1024 512 128];
if length(pixeldim)>0
    AScRes=pixeldim(1);
    BScH=pixeldim(2);
    BScV=pixeldim(3);
end

A=fread(fid,inf,'*uint8');

A=reshape(A,BScH,AScRes,BScV);
A=permute(A,[2,1,3]);
for i=1:BScV
    A(:,:,i)=fliplr(flipud(squeeze(A(:,:,i))));
%     imwrite(A(:,:,i), strcat(PathName,int2str(i),'.bmp'));
end

% A=int16(A);
fclose(fid);

return;