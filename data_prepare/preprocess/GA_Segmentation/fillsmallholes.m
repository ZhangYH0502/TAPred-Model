function new=fillsmallholes(bw,threshold)
% Fill small holes in the binary image bw using the threshold, only holes
% with areas smaller than threshold will be filled

filled = imfill(bw, 'holes');

holes = filled & ~bw;

bigholes = bwareaopen(holes, threshold);

smallholes = holes & ~bigholes;

new = bw | smallholes;