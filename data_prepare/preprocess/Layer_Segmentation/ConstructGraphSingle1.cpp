/*
由于matlab和C的矩阵索引分别为按行和按列，所以调用C程序的时候，传入的矩阵事先要做好转置再传入!
*/
#include "mex.h"
#include "matrix.h"
#include "mat.h"
#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"
#include "block.h"
#include "instances.inc"
#include <fstream>      //输出文件


#define img prhs[0]                         //表示输入参数
#define img_org prhs[1]                     //表示输入参数
#define dx prhs[2]
#define dy prhs[3]
#define result_data plhs[0]                 //表示输出的s割集的点的参数
#define INF 100000
using namespace std;
typedef Graph<int,int,int> GraphType;
GraphType *g = NULL;
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
   	int x,y,z;
    int deltax,deltay;
    int W,H;
    int height,width,dim;
    double *img_matrix,*w_matrix;
	int subindex,subindex2,xsubindex3,xnegsubindex3,xnegsubindex2,ysubindex3,ynegsubindex3,ynegsubindex2;
	
    double *delta_x = mxGetPr(dx);
    double *delta_y = mxGetPr(dy);
    deltax=delta_x[0];        //表示面的限制，目前先设置为2
    deltay=delta_y[0];
    
    double *dims=mxGetPr(img_org);
    height=dims[0];
    width=dims[1];
    dim=dims[2];
    int lenght = height*width*dim;
    mexPrintf("height=%d\n",height);
    mexPrintf("width=%d\n",width);
    mexPrintf("dim=%d\n",dim);
    mexPrintf("lenght=%d\n",lenght);
    int sumBaseWeight=0;
    //获取输入矩阵
	img_matrix=mxGetPr(img);
    W = mxGetM(img); /*获取矩阵的行*/   
    H = mxGetN(img); /*获取矩阵的列*/
    
    mexPrintf("W=%d\n",W);
    mexPrintf("H=%d\n",H);
    
    int s = H;
    int t = H+1;
    int k = 0;
    int *weight = new int[lenght];       //建立权值矩阵
    
     // revised by SJNIU, 5/4,2014.
    int deltax_max = 1;
    int deltay_max = 1;
    
   /*统计边数k*/ 
     for(subindex=0;subindex<lenght;subindex++)
    {
            y=subindex/(height*width);
            x=(subindex-y*(height*width))/height;
            z=subindex%height;
            if(z==0)
            {
                weight[subindex]=img_matrix[subindex];
            }
            else
            {
                weight[subindex]=img_matrix[subindex]-img_matrix[subindex-1];
            }
            if(z-1>=0)
            {
                k++;
            }
            
         // intre arc, hard smoothness constraint. revised by SJNiu 5/2/2014
         // deltax,deltay represents the min distance, deltax_max,deltay_max represents the max distance
         // x-direction
          
         if (z-deltax >= 0)
         {
             if(x+1 <= width-1)
                 k++;
             if (z+deltax_max>=0 && z+deltax_max < height && x+1 <= width-1)
                 k++;
         }
         else
         {
             if (x+1 <= width-1 && z==0) //???是否要k+2
                 k++;
             if (z+deltax_max>=0 && z+deltax_max < height && z==0 && x+1 <= width-1)
                 k++;
         }
        
         //y-direction
         if (z-deltay >= 0)
         {
             if(y+1 <= dim-1)
                 k++;
             if (z+deltay_max>=0 && z+deltay_max < height && y+1 <= dim-1)
                 k++;
         }
         else
         {
             if (y+1 <= dim-1 && z==0) //??? 是否要k+2,如果k+2，则后面要加两条边
                 k++;
             if (z+deltay_max>=0 && z+deltay_max < height && z==0 && y+1 <= dim-1)
                 k++;
         }   
        //end
  
     }
    
    
    int num_V = lenght+2;
    int num_Arc = k;
    mexPrintf("num_V=%d\n",num_V);
    mexPrintf("num_Arc=%d\n",num_Arc); 
    
	g = new GraphType(num_V-2,num_Arc);
    
    //添加顶点
    for(int i=0;i<num_V-2;i++)
	{
		g->add_node();
	}
    
     //计算基面总权值并修改，保证最小闭集的存在
    for(subindex=0;subindex<lenght;subindex+=height)
	{
        weight[subindex]=-1;
		sumBaseWeight+=weight[subindex];
    }
    for(subindex=0;subindex<lenght;subindex++)
    {
            y=subindex/(height*width);
            x=(subindex-y*(height*width))/height;
            z=subindex%height;
            
            if(weight[subindex]>0)
                g->add_tweights(subindex,0,weight[subindex]);
            if(weight[subindex]<0)
            {
                g->add_tweights(subindex,-weight[subindex],0);
            }
   
            //inter-column
            if(z-1>=0)
            {
                subindex2=subindex-1;
                g->add_edge(subindex,subindex2,INF,0);
            }
            
            // intra-column, hard smoothness constraint, revised by SJNIU, 5/2/2014
            // x-direction
            if (z-deltax>=0)
            {
                if(x+1 <= width-1)
                {
                    xsubindex3 = z-deltax + (x+1)*height + y*width*height;
                    g->add_edge(subindex,xsubindex3,INF,0);
                }
                
                if (z+deltax_max>=0 && z+deltax_max < height && x+1 <= width-1)
                {
                    xsubindex3 = z+deltax_max + (x+1)*height + y*width*height;
                    g->add_edge(xsubindex3,subindex,INF,0);
                }
            }
            else
            {
                 if (x+1 <= width-1 && z==0) //???
                 {
                     xnegsubindex3 = z + (x+1)*height + y*height*width;
                     xnegsubindex2 = z + x*height + y*height*width;
                     g->add_edge(xnegsubindex2,xnegsubindex3,INF,INF);
                     //g->add_edge(xnegsubindex3,xnegsubindex2,INF,INF);//是否存在这样的边
                 }
                 
                 if (z+deltax_max>=0 && z+deltax_max < height && z==0 && x+1 <= width-1)
                 {
                     xnegsubindex3 = z+deltax_max + (x+1)*height + y*height*width;
                     xnegsubindex2 = z + x*height + y*height*width;
                     g->add_edge(xnegsubindex3,xnegsubindex2,INF,0);
                 }
            }
            
            // y-direction
            if (z-deltay>=0)
            {
                if(y+1 <= dim-1)
                {
                    ysubindex3 = z-deltay + x*height + (y+1)*width*height;
                    g->add_edge(subindex,ysubindex3,INF,0);
                }
                
                if (z+deltay_max >=0 && z+deltay_max < height && y+1 <= dim-1)
                {
                    ysubindex3 = z+deltay_max + x*height + (y+1)*width*height;
                    g->add_edge(ysubindex3,subindex,INF,0);
                }
            }
            else
            {
                 if (y+1 <= dim-1 && z==0) //???
                 {
                     ynegsubindex3 = z + x*height + (y+1)*height*width;
                     ynegsubindex2 = z + x*height + y*height*width;
                     g->add_edge(ynegsubindex2,ynegsubindex3,INF,INF);
                     //g->add_edge(ynegsubindex3,ynegsubindex2,INF,INF);
                 }
                 
                 if (z+deltay_max >=0 && z+deltay_max < height && z==0 && y+1 <= dim-1)
                 {
                     ynegsubindex3 = z+deltay_max + x*height + (y+1)*height*width;
                     ynegsubindex2 = z + x*height + y*height*width;
                     g->add_edge(ynegsubindex3,ynegsubindex2,INF,0);
                 }
            }
            //end

        }
    
    mexPrintf("begin cal flow...\n");
    int flow = g->maxflow();
    mexPrintf("flow=%d\n",flow);
    result_data = mxCreateDoubleMatrix(1,num_V-2,mxREAL);
    double* result_matrix = mxGetPr(result_data);
    int count = 0;
    /*****************计算出s割集********************/
    
    for(int i=0;i<num_V-2;i++)
	{
		if(g->what_segment(i)==GraphType::SOURCE)
		{
            result_matrix[count++] = i+1; 
		}
	}
    delete g;
    delete weight;
}