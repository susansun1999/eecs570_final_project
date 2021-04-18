// cd /home/hork/cuda-workspace/CudaSHA256/Debug/files
// time ~/Dropbox/FIIT/APS/Projekt/CpuSHA256/a.out -f ../file-list
// time ../CudaSHA256 -f ../file-list


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <cuda.h>
//#include "sha256.cuh"
#include <dirent.h>
#include <ctype.h>
#include <time.h>
#include <sys/time.h>
#include <wb.h>

#define BLOCKSIZE 32
#define ROTLEFT(a,b) (((a) << (b)) | ((a) >> (32-(b))))
#define ROTRIGHT(a,b) (((a) >> (b)) | ((a) << (32-(b))))
#define EP0(x) (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT(x,22))
#define EP1(x) (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT(x,25))
#define CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))


const uint32_t constH[8] = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19};

const uint32_t constK[64] = {0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

const uint32_t constIn[64*BLOCKSIZE] = {0};

__global__ void pre_sha256_cuda(uint32_t* W){
  int startingIdx = 64*threadIdx.x + 16;
  int endingIdx = 64*threadIdx.x + 64;
  for(unsigned i = startingIdx; i < endingIdx; i++){
    uint32_t s0 = ROTRIGHT(W[i-15],7) xor ROTRIGHT(W[i-15],18) xor ROTRIGHT(W[i-15],3);
    uint32_t s1 = ROTRIGHT(W[i-2],17) xor ROTRIGHT(W[i-2],19) xor ROTRIGHT(W[i-2],10);
    W[i] = W[i-16] + s0 + W[i-7] + s1;
  }
}

__global__ void sha256_cuda(uint32_t*K, uint32_t*H, uint32_t* W, uint32_t* out){
  uint32_t a = H[0];
  uint32_t b = H[1];
  uint32_t c = H[2];
  uint32_t d = H[3];
  uint32_t e = H[4];
  uint32_t f = H[5];
  uint32_t g = H[6];
  uint32_t h = H[7];
  unsigned startingIdx = 64 * threadIdx.x;
  for (unsigned i = 0; i < 64; ++i) {
		uint32_t t1 = h + EP1(e) + CH(e, f, g) + K[i] + W[startingIdx + i];
		uint32_t t2 = EP0(a) + MAJ(a, b, c);
		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}
  //out[threadIdx.x*8] = H[0] + a;
  //out[threadIdx.x*8+1] = H[1] + b;
  //out[threadIdx.x*8+2] = H[2] + c;
  //out[threadIdx.x*8+3] = H[3] + d;
  //out[threadIdx.x*8+4] = H[4] + e;
  //out[threadIdx.x*8+5] = H[5] + f;
  //out[threadIdx.x*8+6] = H[6] + g;
  //out[threadIdx.x*8+7] = H[7] + h;
  out[threadIdx.x*8] = 110;
  out[threadIdx.x*8+1] = 110;
  out[threadIdx.x*8+2] = 110;
  out[threadIdx.x*8+3] = 110;
  out[threadIdx.x*8+4] = 110;
  out[threadIdx.x*8+5] = 110;
  out[threadIdx.x*8+6] = 110;
  out[threadIdx.x*8+7] = 110;
}

int main(int argc, char **argv) {
  wbArg_t args;

  uint32_t* hostH = (uint32_t*)malloc(8*sizeof(uint32_t));
  uint32_t* hostK = (uint32_t*)malloc(64*sizeof(uint32_t));
  uint32_t* hostIn = (uint32_t*)malloc(BLOCKSIZE*64*sizeof(uint32_t));
  uint32_t* hostOut = (uint32_t*)malloc(BLOCKSIZE*8*sizeof(uint32_t));
  for(unsigned i = 0; i < 8; i++){
    hostH[i] = constH[i];
  }
  for(unsigned i = 0; i < 64; i++){
    hostK[i] = constK[i];
  }
  for(unsigned i = 0; i < BLOCKSIZE*64; i++){
    //hostIn[i] = constIn[i];
    hostIn[i] = 0x78a5636f;
  }

  uint32_t* deviceH, *deviceK;
  uint32_t* deviceIn; // W
  uint32_t* deviceOut; // H

  cudaMalloc(&deviceH, 8*sizeof(uint32_t));
  cudaMalloc(&deviceK, 64*sizeof(uint32_t));
  cudaMalloc(&deviceIn, 64*BLOCKSIZE*sizeof(uint32_t));
  cudaMalloc(&deviceOut, 8*BLOCKSIZE*sizeof(uint32_t));

  cudaMemcpy(deviceH,hostH,8*sizeof(uint32_t),cudaMemcpyHostToDevice);
  cudaMemcpy(deviceK,hostK,64*sizeof(uint32_t),cudaMemcpyHostToDevice);
  cudaMemcpy(deviceIn,hostIn,64*BLOCKSIZE*sizeof(uint32_t),cudaMemcpyHostToDevice);

  unsigned numBlocks = 1;
  unsigned blockSize = BLOCKSIZE; // warp size

  pre_sha256_cuda <<< numBlocks, blockSize >>> (deviceIn);
  /* get start timestamp */
  struct timeval tv;
  gettimeofday(&tv,NULL);
  uint64_t start = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;

  sha256_cuda <<< numBlocks, blockSize >>> (deviceK, deviceH, deviceIn, deviceOut);
  cudaDeviceSynchronize();

  /* get elapsed time */
  gettimeofday(&tv,NULL);
  uint64_t end = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
  uint64_t elapsed = end - start;

  printf("@@@ Elapsed time (usec): %lld\n", elapsed);

  cudaMemcpy(hostOut,deviceOut,8*BLOCKSIZE*sizeof(uint32_t),cudaMemcpyDeviceToHost);

  for(unsigned i = 0; i < BLOCKSIZE; i++){
    //hostIn[i] = constIn[i];
    for(unsigned j = 0; j < 8; j++){
      printf("%x ",hostOut[i*BLOCKSIZE+j]);
    }
    printf("\n");
  }
  wbTime_start(GPU, "Freeing GPU Memory");

  cudaFree(deviceOut);
  cudaFree(deviceH);
  cudaFree(deviceK);
  cudaFree(deviceOut);

  wbTime_stop(GPU, "Freeing GPU Memory");

  wbSolution(args, hostOut, 8*BLOCKSIZE);

  return 0;
}
