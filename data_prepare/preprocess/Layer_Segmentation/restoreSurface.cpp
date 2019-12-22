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

#define result prhs[0]                      //�������Ϊ���ɵ�s�
#define surfaceNum prhs[1]                 //������
#define subImagelength prhs[2]             //��ͼ�񳤶�
#define delta_l prhs[3]                    //��С�������
#define out plhs[0]                        //��ʾ�������
using namespace std;

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,mxArray *prhs[])
{
    double *result_m = mxGetPr(result);
    double *surfaceNum_m = mxGetPr(surfaceNum);
    double *subImagelength_m = mxGetPr(subImagelength);
    double *delta_l_m = mxGetPr(delta_l);
    
    int num = surfaceNum_m[0];                   //result����Ŀ
    int length = subImagelength_m[0];           //��ͼ��ĳ���
    
    out = mxCreateDoubleMatrix(1,length*num,mxREAL);
    double* out_matrix = mxGetPr(out);
    for(int i = 0;i<mxGetN(result);i++)
    {
        int order = result_m[i]/length;         //��������ڵڼ�������
        int index = result_m[i]-order*length;
        out_matrix[order*length+index-1] = 255;
    }
}