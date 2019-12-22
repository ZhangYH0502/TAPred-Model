function seg = PostProcessing1(segres,oriImg)
bwseg = bwlabel(segres);
row = round(max(bwseg(:))/6+0.5);
stas = regionprops(bwseg,'Centroid');
for i=1:max(bwseg(:))
    [row1 col1] = find(bwseg==i);
    dis1(i) = mean(sqrt(((row1./(max(size(oriImg)))-size(oriImg,1)/(2*max(size(oriImg))))).^2+((col1./(max(size(oriImg)))-size(oriImg,2)/(2*max(size(oriImg))))).^2));
    [p v] = imhist(oriImg(bwseg(:)==i));
    RegionP(:,i) = p;
    [r1 c1] = find(p>0);
    maxP(i) = r1(end)/255;
    number(i) = sum(bwseg(:)==i);
    avg(i) = mean(oriImg(bwseg(:)==i));
    center(i,:) = stas(i,1).Centroid;
%     subplot(row,6,i);imhist(oriImg(bwseg(:)==i));
end
%     seed = RegionP(:,id);
%     num = sum(RegionP(:,number==max(number))>0);
%     dis = 1./dis1;
%     RV = [];
%     for j=1:max(bwseg(:))
%             [r pv] = corr(seed,RegionP(:,j));
%             cor(j) = r;
%             num2 = sum(seed & RegionP(:,j));
%             num3 = sum(RegionP(:,j)>0);
% %             RV = [RV dis(j)*(num2/num)*(sum(RegionP(:,avg==max(avg))>0)/num)];
%             RV = [RV dis1(j)*(num2/num)*(sum(RegionP(:,id)>0)/num)];
%     end
    seg = zeros(size(oriImg));
    avg(maxP<0.5)=1;
    dis1(maxP<0.5)=1;
sa = 0.1*avg+0.9*dis1;
sa = avg./dis1;
if length(maxP)<=1
    sa = sa+1;
end

[maxV Ix] = max(sa);
avgg = abs(avg-avg(Ix));
% diss = sqrt((center(:,1)-center(Ix,1)).^2+(center(:,2)-center(Ix,2)).^2);
diss = abs(dis1-min(dis1));
% for i=1:length(diss)
%     if (diss(i)<0.37 & avgg(i)<0.1)
%         IDX1 = find(bwseg(:)== i);
%         seg(IDX1)=1;
%     end
% end
    IDX = find(sa>1.3 & dis1<0.38);
    for i=1:length(IDX)
        IDX1 = find(bwseg(:)==IDX(i));
        seg(IDX1)=1;
    end
end