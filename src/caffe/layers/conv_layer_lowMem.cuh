#ifndef CONV_LAYER_CUH
#define CONV_LAYER_CUH

#include "cuda.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "caffe/blob.hpp"

using namespace std;


namespace caffe {

// low-memory convolution

/*
inputs: 
  num_output //#filters
  num_channels = CHANNELS_
  height_in = HEIGHT_
  width_in = WIDTH_
  height_out
  width_out
  stride //same for x and y
  kernelSize //convolution filter dim. same for x and y... ignores depth
  imgID "n" //within batch
  groupID "g" //typically 0 or 1

  float* bottom //input (base ptr for beginning of batch)
  float* top    //output
*/


template <typename Dtype>
__global__ void Conv_gpu_lowMem_kernel(Dtype* bottom_data, Dtype* top_data,
                                       int stride, int kernelSize, int num_channels, int height_in, int width_in,
                                       int num_output, int height_out, int width_out,
                                       int imgID, int numGroups, int groupID)
{
    //top-left anchor in input image:
    int x = (blockIdx.x*blockDim.x + threadIdx.x);
    int y = (blockIdx.y*blockDim.y + threadIdx.y);

    //filter ID:
    int f = (blockIdx.z*blockDim.z + threadIdx.z);

    Dtype output_px = 0.0f; //calculate in this register, then write to output buffer

    for(int ch=0; ch < num_channels; ch++)
    {
        for(int localY=0; localY < kernelSize; localY++)
        {
            for(int localX=0; localX < kernelSize; localX++)
            {


            }
        }
    }

    int outputIdx = imgID   * (numGroups * num_output * height_out * width_out) +
                    groupID * (num_output * height_out * width_out) +
                    f       * (height_out * width_out) +
                    y       * (width_out) + x; 

    top_data[outputIdx] = output_px;
}


// wrapper ... launches the conv kernel.
// for now, this processes ONE IMAGE (one item in a batch)
template <typename Dtype>
void Conv_gpu_lowMem(const vector<Blob<Dtype>*>& bottom, vector<Blob<Dtype>*>* top,
                     int stride, int kernelSize, int num_channels, int height_in, int width_in,
                     int num_output, int height_out, int width_out,
                     int imgID, int numGroups, int groupID)
{
    dim3 grid;
    dim3 block;
    block.x = 16;
    block.y = 16;
    block.z = 4; //tune?
    int nx = width_out / (block.x*1); 
    int ny = height_out / (block.y*1);
    int nz = num_output; // # of 3D filters
    grid.x = (width_out % block.x == 0) ? nx : nx+1;
    grid.y = (height_out % block.y == 0) ? ny : ny+1;
    grid.z = (num_output % block.z == 0) ? nz : nz+1;

    Dtype* bottom_data = bottom[0]->gpu_data();
    Dtype* top_data = (*top)[0]->mutable_gpu_data();

    Conv_gpu_lowMem_kernel <<< grid, block >>> (bottom_data, top_data,
                                                stride, kernelSize, num_channels, height_in, width_in,
                                                num_output, height_out, width_out,
                                                imgID, numGroups, groupID);    
}

void hello_cuda()
{
}

template <typename Dtype>
void hello_cuda_template()
//void hello_cuda_template(const vector<Blob<Dtype>*>& bottom)
{

}


} // close Caffe class

#endif
