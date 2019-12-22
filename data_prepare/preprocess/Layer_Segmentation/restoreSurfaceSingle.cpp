/*
 * function r=restoreSurface(s_result,img)
%s_result ------- the result s point sets of the algorithm before
[height,width,dim]=size(img);
r=zeros(size(img));
for m=1:size(s_result,2)
    u=s_result(m);
    [z,x,y]=ind2sub(size(img),u);
    %r(height-z+1,x,y)=255;   
    r(z,x,y)=255;
end
return  
*/

#include "mex.h"
#include "matrix.h"
#include <iostream>

#define s_result prhs[0]            //�������Ϊ���ɵ�s�
#define vol prhs[1]                 //��Ҫ��ԭ���ľ���
#define out plhs[0]                 //����Ľ��
using namespace std;

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,mxArray *prhs[])
{
     int xDir,yDir,zDir;
     int index;
     const int* dims = mxGetDimensions(vol);
     int height = dims[0];
     int length = dims[1];
     int slice = dims[2];
     
     int lengthOfVol = mxGetN(s_result);
     double* s_resultMatrix = mxGetPr(s_result);
     out = mxCreateDoubleMatrix(1,height*length*slice,mxREAL);
     double* outMatrix = mxGetPr(out);
     
     mexPrintf("lengthOfVol=%d\n",lengthOfVol);
     for(int i = 0;i<lengthOfVol;i++)
     {
         /*����index�����x,y,z���������*/
         index = s_resultMatrix[i];
         //yDir = index/(height*length);              //y���������
         //xDir = (index - height*length*yDir)/height;       //x���������
         //zDir = index%height;
         outMatrix[index-1] = 255;
     }
}