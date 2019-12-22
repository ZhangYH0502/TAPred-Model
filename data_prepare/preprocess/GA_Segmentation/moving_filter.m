function fliterprojectimg=moving_filter(file)
%????????
windowsize=9;
y1=filter(ones(1,ceil(windowsize/2))/windowsize,1,file(:));
y2=filter(ones(1,ceil(windowsize/2))/windowsize,1,fliplr(file(:)));
y3=y1+fliplr(y2)-(1/windowsize)*file(:);
fliterprojectimg=(y3);
end