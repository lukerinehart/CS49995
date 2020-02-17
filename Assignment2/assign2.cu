// Luke Rinehart
// GPU parallel processing Assignment 2
// GPU N average sort

#include <cuda.h>
#include <cuda_runtime.h>
#include <time.h>
#include <stdio.h>

const int size = 100;

void gpu_avg(int [size][size], int *,  int);

__global__ void n_avg(int A[size][size], int *B, int k){

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int sum = 0;
  int count = 0;
  printf("{%i}", row);

  if(row < size) {
   for(int i = 0; i < k; ++i) {
       sum += A[row][i];
       count = count + 1;
   }

   B[count] = sum;

 }

}

void gpu_avg(int A[size][size], int *B, int k){
   int Ad[size][size];
   int *Bd;

   dim3 blocks(32,32);
   dim3 grids(1,1);

   cudaMalloc((void**)&Ad, k);
   cudaMemcpy(Ad,A,k*k,cudaMemcpyHostToDevice);
   cudaMalloc((void**)&Bd, k);                        /*Allocate Space for A & B on Device*/
   cudaMemcpy(Bd,B,k,cudaMemcpyHostToDevice);

   n_avg<<<grids,blocks>>>(Ad,Bd,k);         /* Run Average*/

   cudaFree(Ad);
   cudaFree(Bd);  /* Free mem */

}

int main()
{
 //int size = 100;
 int A[size][size]; // 10,000 values
 int result[size];

 srand(time(0));
    for(int i = 0; i < size; ++i){
       result[i] = 0;
       for(int j = 0; j < size; ++j){
          A[i][j] =  rand() % 100;
        }
    }

 cudaEvent_t start, stop;
 cudaEventCreate(&start);
 cudaEventCreate(&stop);

 cudaEventRecord(start);

 gpu_avg(A,result,size);

 cudaEventRecord(stop);
 cudaEventSynchronize(stop);

 float milliseconds = 0;
 cudaEventElapsedTime(&milliseconds, start, stop);   /* Report Time */
 printf("%f ms\n", milliseconds);

 return 0;
}

