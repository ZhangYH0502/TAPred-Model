/*
 * 图割主程序:包含构图，权值构造，以及利用max-flow算法计算出最优解
 * 混编程序交由matlab调用，入口函数为mexFunction
 * note:由于matlab和C的矩阵索引分别为按行和按列，所以调用C程序的时候，传入的矩阵事先要做好转置再传入!
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
#define costVector prhs[0]        //输入参数0，表示第一个子图像矩阵，自身是一个cell数组
#define dims prhs[1]             //表示子图像矩阵的维度（所有子图像大小一样）
#define delta_l prhs[2]          //面间最小距离数组
#define delta_u prhs[3]          //面间最大距离数组
#define delta_x prhs[4]          //表示列间限制x方向
#define delta_y prhs[5]          //表示列间限制y方向，不同的表面采用不同的限制
#define result_data plhs[0]      //表示输出的S集的个数

#define INF 100000                  //表示无穷大
#define NUM 10                      //表示mat子图像数组的大小
using namespace std;
typedef Graph<int,int,int>GraphType;            //库函数的类型重定义
GraphType *g=NULL;
int s,t;                                        //表示source和sink的序号
int deltax_max = 1;
int deltay_max = 1;

/*******************************
 *函数名:CalArcNumOfInterAndExtra
 *函数功能:计算列内和列间弧
 *参数说明：
 * v_m：表示子图像矩阵
 * weight:表示n个子图像的权值矩阵
 * length:表示每一个子图像的长度
 * surfaceNum:表示表面的数目
 * height：表示子图像的高度
 * width：表示子图像的宽度
 * dim：表示子图的维度
 * delta_x,delta_y:表示子图像x和y方向的限制
 ******************************/
inline int CalArcNumOfInterAndExtra(double *v_m,int *weight,int length,int height,int width,int dim,int deltax,int deltay)
{
    int x,y,z;
    int Arc_Num=0;
    for(int subindex=0;subindex<length;subindex++)
    {
        //计算v1中各点的索引
         y=subindex/(height*width);
         x=(subindex-y*(height*width))/height;
         z=subindex%height;
         
         if(z==0)           //表示是base面
         {
             weight[subindex]=v_m[subindex];
         }
         else
         {
             weight[subindex]=v_m[subindex]-v_m[subindex-1];
         }    
         if(z-1>=0)         //列内弧
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
 *函数名:CalArcBetweenImage
 *函数功能:计算子图像之间的弧的个数
 *参数说明:
 *v1_m:表示子图像1
 *v2_m:表示子图像2
 *length:表示子图像的像素个数
 *width:表示子图像的宽度
 *height：表示子图像的高度
 *dim:表示子图像的维度
 *delta_l12：表示1,2之间的最小距离
 *delta_u12: 表示1,2之间的最大距离
 *down1: 表示v1的最低距离
 *down2:表示v2的最低距离
 *************************************/
inline int CalArcBetweenImage(double* v1_m,double* v2_m,int length,int height,int width,int dim,int delta_l12,int delta_u12,int down1,int down2)
{
    int x,y,z;
    int Arc_Num=0;
    //从v1到v2
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
 *函数名:ConstructArcOfInterAndExtra
 *函数功能:构造各子图像的边
 *函数参数说明:
 *v_m:图像矩阵
 *weight:权值矩阵
 *length:子图像的像素个数
 *height：子图像高度
 *width：子图像宽度
 *dim:  子图像维度
 *delta_x,delta_y:面间限制
 *add_length：计算索引时的补偿
 ****************************/
inline void ConstructArcOfInterAndExtra(double *v_m,int *weight,int length,int height,int width,int dim,int deltax,int deltay,int add_length)
{
    int x,y,z;
    for(int subindex=0;subindex<length;subindex++)
    {
        //计算v1中各点的索引
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
         
         if(z-1>=0)         //列内弧
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
 *函数名:ConstructArcBetweenImage
 *函数功能:建立子图像之间的弧的限制
 *参数说明: 
 *v1_m:表示子图像1
 *v2_m:表示子图像2
 *length:表示子图像的像素个数
 *width:表示子图像的宽度
 *height：表示子图像的高度
 *dim:表示子图像的维度
 *delta_l12：表示1,2之间的最小距离
 *delta_u12: 表示1,2之间的最大距离
 *down1: 表示v1的最低距离
 *down2:表示v2的最低距离
 *add_length:表示计算索引时的补偿
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
    //添加一条保证闭集的弧
    g->add_edge(0+add_length,length+add_length,INF,0);
}



/*
 * 混编调用函数入口
 * mexFunction混编入口函数
 */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
       //获取子图像的长宽高（每个子图像的长宽高是一样的）
       int height,width,dim;
       int i,j;
       double* dims_m = mxGetPr(dims);
       height = dims_m[0];
       width = dims_m[1];
       dim = dims_m[2];
       int x,y,z;
       double *delta_u_m = mxGetPr(delta_u);        //获取最大距离数组
       double *delta_l_m = mxGetPr(delta_l);        //获取最小距离数组
       int down1,down2;
       int sumDeltaL = 0;                           //统计所有delta_l的和
       int surfaceNum = mxGetN(costVector);                   //获取子图像的个数
       mexPrintf("surfaceNum=%d\n",surfaceNum);
       
       mxArray** image = new mxArray*[surfaceNum];           //生成相应个数的矩阵
       double** image_v = new double*[surfaceNum];
       
       double *delta_x_m = mxGetPr(delta_x);
       double *delta_y_m = mxGetPr(delta_y);
       for(i = 0;i<surfaceNum-1;i++)
       {
           sumDeltaL += delta_l_m[i];
       }
       //初始化子图像，获取子图像数据
       for(i=0;i<surfaceNum;i++)
       {
           image[i]=mxGetCell(costVector,i);
           image_v[i]=mxGetPr(image[i]);
       }
       
       int length_subImage = mxGetN(image[0]);            //获取每个子图像的顶点个数
       int length = length_subImage*surfaceNum;          //获取所有子图像的顶点个数
       s = length;
       t = length+1;
       
       //定义权值矩阵
       int **weight=new int*[surfaceNum];
       for(i=0;i<surfaceNum;i++)
       {
           weight[i]=new int[length_subImage];
       }
      int Arc_Num = 0;                  //定义构图中的弧的条数
      int point_Num = s;
     //计算出弧的条数     
      mexPrintf("debug before...\n");
     //计算出各个子图像当中的弧的条数
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
     //创建图
     g=new GraphType(point_Num,Arc_Num);
     mexPrintf("debug 3...\n");
     //添加点
     for(int i=0;i<point_Num;i++)
     {
         g->add_node();
     }
     //修改各个子图像base面权值
     for(i=0;i<surfaceNum;i++)
     {
         for(int subindex=0;subindex<length_subImage;subindex+=height)
         {
             weight[i][subindex]=-1;
         }
     }
     
     //构图
     //构造每个子图像的图
     mexPrintf("debug 4...\n");
     for(i = 0 ;i<surfaceNum;i++)
     {
        ConstructArcOfInterAndExtra(image_v[i],weight[i],length_subImage,height,width,dim,delta_x_m[i],delta_y_m[i],i*length_subImage);
     }
 
    //构造子图像之间的弧的关系
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
     /*****************计算出s割集********************/
      
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
