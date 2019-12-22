function [G1,G2] = FLICM_alg(Img,C1,C2)%U11,U22,
[m,n]=size(Img);
G1=zeros([m,n]);
G2=zeros([m,n]);
mm=2;
for i=1:m
    for j=1:n
           temp1=0;temp2=0;
           for x=i-1:i+1
                for y=j-1:j+1 
                    if x>0&&x<m&&y>0&&y<n&&(x~=i||y~=j)                         
                        d=sqrt((i-x)^2+(j-y)^2); 
                        temp1=temp1+1/(1+d)*(Img(x,y)-C1)^2;%加速惩罚项((1-U1(x,y))^mm)*
                        temp2=temp2+1/(1+d)*(Img(x,y)-C2)^2;%加速惩罚项((1-U2(x,y))^mm)*
                    end
                end
           end
           G1(i,j) = temp1;
           G2(i,j) = temp2;
           
           sSum = ((Img(i,j)-C1)+G1(i,j))/abs(Img(i,j)-C1)+G1(i,j)+((Img(i,j)-C1)+G1(i,j))/abs(Img(i,j)-C2)+G2(i,j);
%            U11(i,j) = 1/(sSum)^(1/(mm-1));
%            U22(i,j) = 1/(sSum)^(1/(mm-1));
        end
end
end
