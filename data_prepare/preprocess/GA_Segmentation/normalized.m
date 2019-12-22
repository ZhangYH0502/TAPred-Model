function Img = normalized(Im)
Im = double(Im);
Img = (Im-min(Im(:)))/(max(Im(:))-min(Im(:)));
return