#include<iostream>
#include <sys/time.h>

int32_t rightrotate(int32_t in, int bits){
    int32_t lower = in >> bits;
    int32_t upper = in << (32-bits);
    return lower | upper;
}

const int32_t K = [
           0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
           0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
           0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
           0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
           0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
           0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
           0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
           0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 ];



void SHA256(int32_t H[]){
    // Prepare W
    for (size_t i = 0; i < 16; ++i)
        W[i] = bswap_32(W[i]);
    for (size_t i = 16; i < 64; ++i)
        W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15]) + W[i-16];
    
    uint32_t a = H[0];
    uint32_t b = H[1];
    uint32_t c = H[2];
    uint32_t d = H[3];
    uint32_t e = H[4];
    uint32_t f = H[5];
    uint32_t g = H[6];
    uint32_t h = H[7];

    for(int i = 0; i < 64; i++){
        uint32_t S1 = rightrotate(e,6) ^ rightrotate(e,11) ^ rightrotate(e,25);
        uint32_t ch = (e & f) ^ ((~ e) & g);
        uint32_t tmp1 = h + S1 + ch + k[i] + w[i];
        uint32_t S0 = rightrotate(a,2) ^ rightrotate(a,13) ^ rightrotate(a,22);
        uint32_t maj = (a & b)^(a & c)^(b & c);
        uint32_t tmp2 = S0 + maj;
        
        h = g;
        g = f;
        f = e;
        e = d + tmp1;
        d = c;
        c = b;
        b = a;
        a = tmp1 + tmp2;
    }
    H[0] += a;
    H[1] += b;
    H[2] += c;
    H[3] += d;
    H[4] += e;
    H[5] += f;
    H[6] += g;
    H[7] += h;
}

int main(){
    uint32_t H[] = {
    0x6a09e667UL, 0xbb67ae85UL, 0x3c6ef372UL, 0xa54ff53aUL, 0x510e527fUL, 0x9b05688cUL, 0x1f83d9abUL, 0x5be0cd19UL
    };
	struct timeval tv;
  	gettimeofday(&tv,NULL);
	uint64_t start = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
    SHA256(H);
 gettimeofday(&tv,NULL);
 uint64_t end = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
 uint64_t elapsed = end - start;

 printf("it: %d @@@ Elapsed time (usec): %lld\n",times, elapsed);
    return 0;
}
