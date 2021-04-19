#include <iostream>
#include <cstdio>
#include <cmath>
#include <math.h>
#include <float.h>
#define BLOCKSIZE 1024
#define BLOCKDIM 32
using namespace std;

__device__ double find2Smallest(double arr[], int arr_size)  
{  
    int i;
    double first = DBL_MAX, second = DBL_MAX;
  
    for (i = 0; i < arr_size ; i ++) {  
        // If current element is smaller than first then update both first and second
        if (arr[i] < first) {  
            second = first;  
            first = arr[i];  
        }  
        // If arr[i] is in between first and second then update second
        else if (arr[i] < second && arr[i] != first)  
            second = arr[i];  
    }  
    return second;
} 

__global__ void MatUpdate(double *dev_A, double *dev_new_A, const int n){
    __shared__ int neighbor[2];
    // double cmp[4];
    neighbor[0] = -1;
    neighbor[1] = 1;
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    int j = threadIdx.y + blockDim.y * blockIdx.y;
    
    if(i > 0 && i < n-1 && j > 0 && j < n-1) {
        double small_1 = DBL_MAX;
        double small_2 = DBL_MAX;
        for (int p : neighbor){
            for (int q : neighbor){
                double x = dev_A[(i + p) * n + (j + q)];
                if (x <= small_1){
                    small_2 = small_1;
                    small_1 = x;
                }
                else if (x < small_2){
                    small_2 = x;
                }
            }
        }
        dev_new_A[i * n + j] = dev_A[i * n + j] + small_2;
    }
}

__global__ void iterationKernel(double* A, double* new_A, size_t n)
{
    __shared__ double sdata[BLOCKSIZE + 4 * BLOCKDIM + 4];
    double cmp[4];
    int row = threadIdx.y + blockIdx.y * blockDim.y;    // global index
	int col = threadIdx.x + blockIdx.x * blockDim.x;
    int local_index = threadIdx.y * blockDim.x + threadIdx.x;
    size_t global_index = row * n + col;

    // load input into __shared__ memory
    sdata[local_index] = 0;
    if (global_index < n * n) {
        sdata[local_index] = A[global_index];

        // Except for blocks in the first col, threads in the first col load their left elements
        if (threadIdx.x == 0 && blockIdx.x != 0) {
            sdata[BLOCKSIZE + threadIdx.y] = A[global_index - 1];
            if (threadIdx.y == 0 && blockIdx.y != 0) sdata[BLOCKSIZE + 4 * BLOCKDIM] = A[global_index - n - 1]; // left up corner
        }
        // Except for blocks in the last col, threads in the last col load their right elements
        if (threadIdx.x == (blockDim.x - 1) && blockIdx.x != (gridDim.x - 1)) {
            sdata[BLOCKSIZE + BLOCKDIM + threadIdx.y] = A[global_index + 1];
            if (threadIdx.y == (blockDim.y - 1) && blockIdx.y != (gridDim.y - 1)) sdata[BLOCKSIZE + 4 * BLOCKDIM + 1] = A[global_index + n + 1]; // right down corner
        }
        // Except for blocks in the first row, threads in the first row load the elements above
        if (threadIdx.y == 0 && blockIdx.y != 0) {
            sdata[BLOCKSIZE + BLOCKDIM * 2 + threadIdx.x] = A[global_index - n];
            if (threadIdx.x == (blockDim.x - 1) && blockIdx.x != (gridDim.x - 1)) sdata[BLOCKSIZE + 4 * BLOCKDIM + 2] = A[global_index - n + 1]; // right up corner
        }
        // Except for blocks in the last row, threads in the last row load the elements below
        if (threadIdx.y == (blockDim.y - 1) && blockIdx.y != (gridDim.y - 1)) {
            sdata[BLOCKSIZE + BLOCKDIM * 3 + threadIdx.x] = A[global_index + n];
            if (threadIdx.x == 0 && blockIdx.x != 0) sdata[BLOCKSIZE + 4 * BLOCKDIM + 3] = A[global_index + n - 1]; // left down corner
        }
    }
    __syncthreads();        // wait for each thread to load the value to shared memory

    // update
    if (row > 0 && col > 0 && row < (n - 1) && col < (n - 1)) {
        if (threadIdx.x == 0) {                             // first col
            if (threadIdx.y == 0) {
                cmp[0] = sdata[BLOCKSIZE + 4 * BLOCKDIM];                       // left up
                cmp[1] = sdata[BLOCKSIZE + threadIdx.y + 1];                    // left down
                cmp[2] = sdata[BLOCKSIZE + BLOCKDIM * 2 + threadIdx.x + 1];     // right up
                cmp[3] = sdata[local_index + blockDim.x + 1];                   // right down
            } else if (threadIdx.y == (blockDim.y - 1)) {
                cmp[0] = sdata[BLOCKSIZE + threadIdx.y - 1];                    // left up
                cmp[1] = sdata[BLOCKSIZE + 4 * BLOCKDIM + 3];                   // left down
                cmp[2] = sdata[local_index - blockDim.x + 1];                   // right up
                cmp[3] = sdata[BLOCKSIZE + BLOCKDIM * 3 + threadIdx.x + 1];     // right down
            } else {
                cmp[0] = sdata[BLOCKSIZE + threadIdx.y - 1];                    // left up
                cmp[1] = sdata[BLOCKSIZE + threadIdx.y + 1];                    // left down
                cmp[2] = sdata[local_index - blockDim.x + 1];                   // right up
                cmp[3] = sdata[local_index + blockDim.x + 1];                   // right down
            }
        } else if (threadIdx.x == (blockDim.x - 1)) {       // last col
            if (threadIdx.y == 0) {
                cmp[0] = sdata[BLOCKSIZE + BLOCKDIM * 2 + threadIdx.x - 1];     // left up
                cmp[1] = sdata[local_index + blockDim.x - 1];                   // left down
                cmp[2] = sdata[BLOCKSIZE + 4 * BLOCKDIM + 2];                   // right up
                cmp[3] = sdata[BLOCKSIZE + BLOCKDIM + threadIdx.y + 1];         // right down
            } else if (threadIdx.y == (blockDim.y - 1)) {
                cmp[0] = sdata[local_index - blockDim.x - 1];                   // left up
                cmp[1] = sdata[BLOCKSIZE + BLOCKDIM * 3 + threadIdx.x - 1];     // left down
                cmp[2] = sdata[BLOCKSIZE + BLOCKDIM + threadIdx.y - 1];         // right up
                cmp[3] = sdata[BLOCKSIZE + 4 * BLOCKDIM + 1];                   // right down
            } else {
                cmp[0] = sdata[local_index - blockDim.x - 1];                   // left up
                cmp[1] = sdata[local_index + blockDim.x - 1];                   // left down
                cmp[2] = sdata[BLOCKSIZE + BLOCKDIM + threadIdx.y - 1];         // right up
                cmp[3] = sdata[BLOCKSIZE + BLOCKDIM + threadIdx.y + 1];         // right down
            }
        } else if (threadIdx.y == 0) {                      // first row
            if (threadIdx.x != 0 && threadIdx.x != (blockDim.x - 1)) {
                cmp[0] = sdata[BLOCKSIZE + BLOCKDIM * 2 + threadIdx.x - 1];     // left up
                cmp[1] = sdata[local_index + blockDim.x - 1];                   // left down
                cmp[2] = sdata[BLOCKSIZE + BLOCKDIM * 2 + threadIdx.x + 1];     // right up
                cmp[3] = sdata[local_index + blockDim.x + 1];                   // right down
            }
        } else if (threadIdx.y == (blockDim.y - 1)) {       // last row
            if (threadIdx.x != 0 && threadIdx.x != (blockDim.x - 1)) {
                cmp[0] = sdata[local_index - blockDim.x - 1];                   // left up
                cmp[1] = sdata[BLOCKSIZE + BLOCKDIM * 3 + threadIdx.x - 1];     // left down
                cmp[2] = sdata[local_index - blockDim.x + 1];                   // right up
                cmp[3] = sdata[BLOCKSIZE + BLOCKDIM * 3 + threadIdx.x + 1];     // right down
            }
        } else {
            cmp[0] = sdata[local_index - blockDim.x - 1];                       // left up
            cmp[1] = sdata[local_index + blockDim.x - 1];                       // left down
            cmp[2] = sdata[local_index - blockDim.x + 1];                       // right up
            cmp[3] = sdata[local_index + blockDim.x + 1];                       // right down
        }
        new_A[global_index] = sdata[local_index] + find2Smallest(cmp, 4);
    }
}


__global__ void sumKernel(double* A, double* per_block_result, size_t n)
{
    __shared__ double sdata[BLOCKSIZE];
    size_t bid = blockIdx.y * gridDim.x + blockIdx.x;
    size_t local_index = threadIdx.y * blockDim.x + threadIdx.x;
    size_t global_index = bid * BLOCKSIZE + local_index;

    // load input into __shared__ memory
    sdata[local_index] = 0;
    if (global_index < n) sdata[local_index] = A[global_index];
    __syncthreads();        // wait for each thread to load the value to shared memory

    for( int stride = BLOCKSIZE / 2; stride > 0; stride >>= 1) {
        if (local_index < stride) sdata[local_index] += sdata[local_index + stride];
        __syncthreads();    // sum is stored in A[0]
    }
    if (local_index == 0) per_block_result[bid] = sdata[0];
}

__global__ void verificationKernel(double* A, double* A_37_47, size_t n)
{
    *A_37_47 = A[37 * n + 47];
}


int main(int argc, char** argv) {
    int n = atoi(argv[1]), t = atoi(argv[2]);
    // Initialize
    int size = n * n ;
    double* A = new double [size];
    double* col_val = new double [n];
    for (int j = 0; j < n; ++j){
      col_val[j] = sin(j);
    }
    for (int i = 0; i < n; ++i){
        double row_val = cos(2*i);
        for (int j = 0; j < n; ++j){
            A[i*n+j] = (1 + row_val + col_val[j])*(1 + row_val + col_val[j]);
        }
    }
    delete [] col_val;
    // for (int i = 0; i <n*n; ++i){
    //     cout<< A[i]<<endl;
    // }
    double A_37_47 = 0;
    double A_sum = 0;

    dim3 blockSize(BLOCKDIM, BLOCKDIM);
    dim3 gridSize((n + blockSize.x - 1) / blockSize.x, (n + blockSize.y - 1) / blockSize.y);

    // Copy from CPU to GPU
    double* dev_A = 0;
    double* dev_new_A = 0;
    double* dev_A_37_47 = 0;
    double* dev_A_sum = 0;
    double *dev_per_block_result;
    int num_block = gridSize.x * gridSize.y;
    int tmp_num_block = num_block > BLOCKSIZE ? num_block / BLOCKSIZE + 1: 1;  // assign block num to store partial sum if num_block is large than 1024
    cudaMalloc((void**)&dev_per_block_result, (num_block + tmp_num_block + 1) * sizeof(double));
    cudaMalloc((void**)&dev_A, size * sizeof(double));
    cudaMalloc((void**)&dev_new_A, size * sizeof(double));
    cudaMalloc((void**)&dev_A_37_47, sizeof(double));
    cudaMalloc((void**)&dev_A_sum, sizeof(double));

    cudaMemcpy(dev_A, A, size * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_new_A, A, size * sizeof(double), cudaMemcpyHostToDevice);

    // Set up timing
    cudaEvent_t start, stop;
    float gpu_time = 0.0f;
    double *swap;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    for (int iter = 0; iter < t; iter++){
        MatUpdate<<<gridSize, blockSize>>>(dev_A, dev_new_A, n);
        cudaDeviceSynchronize();
        swap = dev_A;
        dev_A = dev_new_A;
        dev_new_A = swap;
    }

    verificationKernel <<< 1, 1 >>> (dev_A, dev_A_37_47, n);
    sumKernel <<< gridSize, blockSize >>> (dev_A, dev_per_block_result, size);    
    cudaDeviceSynchronize();
    sumKernel <<< tmp_num_block, blockSize >>> (dev_per_block_result, dev_per_block_result + num_block, num_block);
    if (num_block > BLOCKSIZE) sumKernel <<< 1, blockSize >>> (dev_per_block_result + num_block, dev_per_block_result + num_block + tmp_num_block, tmp_num_block);
    cudaDeviceSynchronize();

    // Close timing
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&gpu_time, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    cudaMemcpy((void*)&A_sum, (void*)(dev_per_block_result + num_block), sizeof(double), cudaMemcpyDeviceToHost);
    if (num_block > BLOCKSIZE) cudaMemcpy((void*)&A_sum, (void*)(dev_per_block_result + num_block + tmp_num_block), sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy((void*)A, (void*)dev_A, size * sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(&A_37_47, dev_A_37_47, sizeof(double), cudaMemcpyDeviceToHost);
    cudaFree(dev_per_block_result);
    cudaFree(dev_A);
    cudaFree(dev_new_A);
    cudaFree(dev_A_37_47);
    cudaFree(dev_A_sum);
    
    cout << fixed;
    cout << "Sum: "<< A_sum << endl;
    cout << "A(37, 47): "<< A_37_47 << endl;
    cout<<"Time: "<<gpu_time<<endl;
    return 0;
}
