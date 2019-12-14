function A_reshape = reshape3Dmatrix(A)

[h, w, ~] = size(A);

A_reshape = zeros(h, w, 512);

for i = 1:w
    Ascan = squeeze(A(:,i,:));
    Ascan = imresize(Ascan, [h 512]);
    A_reshape(:,i,:) = Ascan;  
end