/*
 * ͼ��������:������ͼ��Ȩֵ���죬�Լ�����max-flow�㷨��������Ž�
 * ��������matlab���ã���ں���ΪmexFunction
 * note:����matlab��C�ľ��������ֱ�Ϊ���кͰ��У����Ե���C�����ʱ�򣬴���ľ�������Ҫ����ת���ٴ���!
*/
#include <iostream>
#include <fstream>
#include "mex.h"
#include "matrix.h"
#include "mat.h"
#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"
#include "block.h"
#include "instances.inc"
#define costVector prhs[0]        //�������0����ʾ��һ����ͼ�����������һ��cell����
#define dims prhs[1]             //��ʾ��ͼ������ά�ȣ�������ͼ���Сһ����
#define delta_l prhs[2]          //�����С��������
#define delta_u prhs[3]          //�������������
#define delta_x prhs[4]          //��ʾ�м�����x����
#define delta_y prhs[5]          //��ʾ�м�����y���򣬲�ͬ�ı�����ò�ͬ������
#define result_data plhs[0]      //��ʾ�����S���ĸ���

#define INF 100000                  //��ʾ�����
#define NUM 10                      //��ʾmat��ͼ������Ĵ�С
using namespace std;
typedef Graph<int,int,int>GraphType;            //�⺯���������ض���
GraphType *g=NULL;
int s,t;                                        //��ʾsource��sink�����
int deltax_max = 1;
int deltay_max = 1;

/*******************************
 *������:CalArcNumOfInterAndExtra
 *��������:�������ں��м仡
 *����˵����
 * v_m����ʾ��ͼ�����
 * weight:��ʾn����ͼ���Ȩֵ����
 * length:��ʾÿһ����ͼ��ĳ���
 * surfaceNum:��ʾ�������Ŀ
 * height����ʾ��ͼ��ĸ߶�
 * width����ʾ��ͼ��Ŀ��
 * dim����ʾ��ͼ��ά��
 * delta_x,delta_y:��ʾ��ͼ��x��y���������
 ******************************/
inline int CalArcNumOfInterAndExtra(double *v_m,int *weight,int length,int height,int width,int dim,int deltax,int deltay)
{
    int x,y,z;
    int Arc_Num=0;
    for(int subindex=0;subindex<length;subindex++)
    {
        //����v1�и��������
         y=subindex/(height*width);
         x=(subindex-y*(height*width))/height;
         z=subindex%height;
         
         if(z==0)           //��ʾ��base��
         {
             weight[subindex]=v_m[subindex];
         }
         else
         {
             weight[subindex]=v_m[subindex]-v_m[subindex-1];
         }    
         if(z-1>=0)         //���ڻ�
         {
             Arc_Num++;
         }
         
         // intra arc, hard smoothness constraint. revised by SJNiu 5/2/2014
         // deltax[0] represents the min distance, deltax[1] represents the max distance
         
         //x-direction
         if (z-deltax >= 0)
         {
             if(x+1 <= width-1)
                 Arc_Num++;
             if (z+deltax_max < height && x+1 <= width-1)
                 Arc_Num++;
         }
         else
         {
             if (x+1 <= width-1 && z==0) //???
                 Arc_Num++;
             if (z+deltax_max < height && z==0 && x+1 <= width-1)
                 Arc_Num++;
         }
         
         //y-direction
         if (z-deltay >= 0)
         {
             if(y+1 <= dim-1)
                 Arc_Num++;
             if (z+deltay_max < height && y+1 <= dim-1)
                 Arc_Num++;
         }
         else
         {
             if (y+1 <= dim-1 && z==0) //???
                 Arc_Num++;
             if (z+deltay_max < height && z==0 && y+1 <= dim-1)
                 Arc_Num++;
         }
         //
    }
    return Arc_Num;
}
/*************************************
 *������:CalArcBetweenImage
 *��������:������ͼ��֮��Ļ��ĸ���
 *����˵��:
 *v1_m:��ʾ��ͼ��1
 *v2_m:��ʾ��ͼ��2
 *length:��ʾ��ͼ������ظ���
 *width:��ʾ��ͼ��Ŀ��
 *height����ʾ��ͼ��ĸ߶�
 *dim:��ʾ��ͼ���ά��
 *delta_l12����ʾ1,2֮�����С����
 *delta_u12: ��ʾ1,2֮���������
 *down1: ��ʾv1����;���
 *down2:��ʾv2����;���
 *************************************/
inline int CalArcBetweenImage(double* v1_m,double* v2_m,int length,int height,int width,int dim,int delta_l12,int delta_u12,int down1,int down2)
{
    int x,y,z;
    int Arc_Num=0;
    //��v1��v2
    for(int subindex=0;subindex<length;subindex++)
    {
         y=subindex/(height*width);
         x=(subindex-y*(height*width))/height;
         z=subindex%height;
         z=z+down1;
         if(z-delta_u12>=down2)
         {
             if(z-delta_u12>down2)
             {
                 Arc_Num++;
             }
         }
    }
    for(int subindex=0;subindex<length;subindex++)
    {
         y = subindex/(height*width);
         x = (subindex-y*(height*width))/height;
         z = subindex%height;
         z = z+down2;
         if(z+delta_l12<=height+down1-1)
         {
                 Arc_Num++;
         }
    }
    Arc_Num=Arc_Num+1;
    return Arc_Num;
}
/*****************************
 *������:ConstructArcOfInterAndExtra
 *��������:�������ͼ��ı�
 *��������˵��:
 *v_m:ͼ�����
 *weight:Ȩֵ����
 *length:��ͼ������ظ���
 *height����ͼ��߶�
 *width����ͼ����
 *dim:  ��ͼ��ά��
 *delta_x,delta_y:�������
 *add_length����������ʱ�Ĳ���
 ****************************/
inline void ConstructArcOfInterAndExtra(double *v_m,int *weight,int length,int height,int width,int dim,int deltax,int deltay,int add_length)
{
    int x,y,z;
    for(int subindex=0;subindex<length;subindex++)
    {
        //����v1�и��������
         y=subindex/(height*width);
         x=(subindex-y*(height*width))/height;
         z=subindex%height;
         
         if(weight[subindex]>0)
         {
            g->add_tweights(subindex+add_length,0,weight[subindex]);
//             ofs<<subindex+add_length+1<<" "<<t+1<<" "<<weight[subindex]<<" 0"<<"\n";
         }
         if(weight[subindex]<0)
         {
            g->add_tweights(subindex+add_length,-weight[subindex],0);
//             ofs<<s+1<<" "<<subindex+add_length+1<<" "<<-weight[subindex]<<" 0"<<"\n";
         }
         
         if(z-1>=0)         //���ڻ�
         {
             int subindex2=subindex-1;
             g->add_edge(subindex+add_length,subindex2+add_length,INF,0);
//              ofs<<subindex+add_length+1<<" "<<subindex2+add_length+1<<" "<<INF<<" "<<0<<"\n";
         }
         
         // intra-column, hard smoothness constraint, revised by SJNIU 5/3,2014
         // x-direction
         if (z-deltax>=0)
         {
             if (x+1 <= width-1)
             {
                 int xsubindex3=z-deltax+(x+1)*height+y*width*height;
                 g->add_edge(subindex+add_length,xsubindex3+add_length,INF,0);
             }
             
             if (z+deltax_max < height && x+1 <= width-1)
             {
                 int xsubindex3 = z+deltax_max + (x+1)*height + y*width*height;
                 g->add_edge(xsubindex3+add_length,subindex+add_length,INF,0);
             }
         }
         else
         {
             if (x+1 <= width-1 && z==0)
             {
                 int xnegsubindex3 = z + (x+1)*height + y*height*width;
                 int xnegsubindex2 = z + x*height + y*height*width;
                 g->add_edge(xnegsubindex2+add_length,xnegsubindex3+add_length,INF,INF);
             }
             
             if (z+deltax_max < height && z==0 && x+1 <= width-1)
             {
                 int xnegsubindex3 = z+deltax_max + (x+1)*height + y*height*width;
                 int xnegsubindex2 = z + x*height + y*height*width;
                 g->add_edge(xnegsubindex3+add_length,xnegsubindex2+add_length,INF,0);
             }
         }
         
         // y-direction
         if (z-deltay>=0)
         {
             if (y+1 <= dim-1)
             {
                 int ysubindex3 = z-deltay + x*height + (y+1)*height*width;
                 g->add_edge(subindex+add_length,ysubindex3+add_length,INF,0);
             }
             
             if (z+deltay_max < height && y+1 <= dim-1)
             {
                 int ysubindex3 = z+deltay_max + x*height + (y+1)*width*height;
                 g->add_edge(ysubindex3+add_length,subindex+add_length,INF,0);
             }
         }
         else
         {
             if (y+1 <= dim-1 && z==0)
             {
                 int ynegsubindex3 = z + x*height + (y+1)*width*height;
                 int ynegsubindex2 = z + x*height + y*width*height;
                 g->add_edge(ynegsubindex2+add_length,ynegsubindex3+add_length,INF,INF);
             }
             
             if (z+deltay_max < height && z==0 && y+1 <= dim-1)
             {
                 int ynegsubindex3 = z+deltay_max + x*height + (y+1)*height*width;
                 int ynegsubindex2 = z + x*height + y*height*width;
                 g->add_edge(ynegsubindex3+add_length,ynegsubindex2+add_length,INF,0);
             }
         }
         //end revised by SJNIU
    }
}

/**************************************
 *������:ConstructArcBetweenImage
 *��������:������ͼ��֮��Ļ�������
 *����˵��: 
 *v1_m:��ʾ��ͼ��1
 *v2_m:��ʾ��ͼ��2
 *length:��ʾ��ͼ������ظ���
 *width:��ʾ��ͼ��Ŀ��
 *height����ʾ��ͼ��ĸ߶�
 *dim:��ʾ��ͼ���ά��
 *delta_l12����ʾ1,2֮�����С����
 *delta_u12: ��ʾ1,2֮���������
 *down1: ��ʾv1����;���
 *down2:��ʾv2����;���
 *add_length:��ʾ��������ʱ�Ĳ���
 *************************************/
inline void ConstructArcBetweenImage(double* v1_m,double* v2_m,int length,int height,int width,int dim,int delta_l12,int delta_u12,int down1,int down2,int add_length)
{
    int x,y,z;
    for(int subindex=0;subindex<length;subindex++)
    {
         y = subindex/(height*width);
         x = (subindex-y*(height*width))/height;
         z = subindex%height;
         z = z+down1;
         if(z-delta_u12 >= down2)
         {
             if(z-delta_u12 >down2)
             {
                 int x1 = x;
                 int y1 = y;
                 int z1 = z-delta_u12-down2;
                 int subindex2 = y1*height*width+x1*height+z1+length;
                 g->add_edge(subindex+add_length,subindex2+add_length,INF,0);
             }
         }
    }
    mexPrintf("debug 22...\n");
    for(int subindex=0;subindex<length;subindex++)
    {
         y = subindex/(height*width);
         x = (subindex-y*(height*width))/height;
         z = subindex%height;
         z = z + down2;
         if(z+delta_l12<=height+down1-1)
         {
              int subindex2 = subindex;
              g->add_edge(subindex+length+add_length,subindex2+add_length,INF,0);
         }
    }
    mexPrintf("debug 33...\n");
    //���һ����֤�ռ��Ļ�
    g->add_edge(0+add_length,length+add_length,INF,0);
}



/*
 * �����ú������
 * mexFunction�����ں���
 */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
       //��ȡ��ͼ��ĳ���ߣ�ÿ����ͼ��ĳ������һ���ģ�
       int height,width,dim;
       int i,j;
       double* dims_m = mxGetPr(dims);
       height = dims_m[0];
       width = dims_m[1];
       dim = dims_m[2];
       int x,y,z;
       double *delta_u_m = mxGetPr(delta_u);        //��ȡ����������
       double *delta_l_m = mxGetPr(delta_l);        //��ȡ��С��������
       int down1,down2;
       int sumDeltaL = 0;                           //ͳ������delta_l�ĺ�
       int surfaceNum = mxGetN(costVector);                   //��ȡ��ͼ��ĸ���
       mexPrintf("surfaceNum=%d\n",surfaceNum);
       
       mxArray** image = new mxArray*[surfaceNum];           //������Ӧ�����ľ���
       double** image_v = new double*[surfaceNum];
       
       double *delta_x_m = mxGetPr(delta_x);
       double *delta_y_m = mxGetPr(delta_y);
       for(i = 0;i<surfaceNum-1;i++)
       {
           sumDeltaL += delta_l_m[i];
       }
       //��ʼ����ͼ�񣬻�ȡ��ͼ������
       for(i=0;i<surfaceNum;i++)
       {
           image[i]=mxGetCell(costVector,i);
           image_v[i]=mxGetPr(image[i]);
       }
       
       int length_subImage = mxGetN(image[0]);            //��ȡÿ����ͼ��Ķ������
       int length = length_subImage*surfaceNum;          //��ȡ������ͼ��Ķ������
       s = length;
       t = length+1;
       
       //����Ȩֵ����
       int **weight=new int*[surfaceNum];
       for(i=0;i<surfaceNum;i++)
       {
           weight[i]=new int[length_subImage];
       }
      int Arc_Num = 0;                  //���幹ͼ�еĻ�������
      int point_Num = s;
     //�������������     
      mexPrintf("debug before...\n");
     //�����������ͼ���еĻ�������
      i=0;
      for(i = 0;i<surfaceNum;i++)
      {
         Arc_Num += CalArcNumOfInterAndExtra(image_v[i],weight[i],length_subImage,height,width,dim,delta_x_m[i],delta_y_m[i]);
      }
      
      mexPrintf("Arc_num=%d\n",Arc_Num);
      
      down1 = sumDeltaL;
      for(i = 0;i<surfaceNum-1;i++)
      {
         down2 = down1-delta_l_m[i];
         Arc_Num += CalArcBetweenImage(image_v[i],image_v[i+1],length_subImage,height,width,dim,delta_l_m[i],delta_u_m[i],down1,down2);
         down1 = down1 -delta_l_m[i];
      }     
     //����ͼ
     g=new GraphType(point_Num,Arc_Num);
     mexPrintf("debug 3...\n");
     //��ӵ�
     for(int i=0;i<point_Num;i++)
     {
         g->add_node();
     }
     //�޸ĸ�����ͼ��base��Ȩֵ
     for(i=0;i<surfaceNum;i++)
     {
         for(int subindex=0;subindex<length_subImage;subindex+=height)
         {
             weight[i][subindex]=-1;
         }
     }
     
     //��ͼ
     //����ÿ����ͼ���ͼ
     mexPrintf("debug 4...\n");
     for(i = 0 ;i<surfaceNum;i++)
     {
        ConstructArcOfInterAndExtra(image_v[i],weight[i],length_subImage,height,width,dim,delta_x_m[i],delta_y_m[i],i*length_subImage);
     }
 
    //������ͼ��֮��Ļ��Ĺ�ϵ
     mexPrintf("debug 6...\n");
     down1 = sumDeltaL;
     for(i = 0;i<surfaceNum-1;i++)
     {  
        down2 = down1-delta_l_m[i];
        ConstructArcBetweenImage(image_v[i],image_v[i+1],length_subImage,height,width,dim,delta_l_m[i],delta_u_m[i],down1,down2,i*length_subImage);
     }
     mexPrintf("debug 7...\n");
     int flow = g->maxflow();
     mexPrintf("flow=%d\n",flow);
     result_data = mxCreateDoubleMatrix(1,point_Num,mxREAL);
     double* result_matrix = mxGetPr(result_data);
     int count = 0;
     /*****************�����s�********************/
      
     mexPrintf("debug 8...\n");
     for(int i=0;i<point_Num;i++)
 	{
 		if(g->what_segment(i)==GraphType::SOURCE)
 		{
             result_matrix[count++] = i+1; 
 		}
 	}
     
     delete g;
     /**/
//      for(i=0;i<surfaceNum;i++)
//      {
//          delete []weight[i];
//          delete []image[i];
//          delete []image_v[i];
//      }
//      delete []weight;
//      delete []image;
//      delete []image_v;
}
