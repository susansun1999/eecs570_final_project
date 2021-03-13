#include "sha.hh"
#include <byteswap.h>
using namespace std;

const array<uint32_t, 8>* SHA256::Hash(istream& is)
{
    // Processing 512-bit (64-byte) blocks
    H = H0;
    uint32_t W[64];
    uint64_t curr_size = 0ULL;
    char* W_b = reinterpret_cast<char*>(W);
    uint64_t* bit_sz_ptr = reinterpret_cast<uint64_t*>(W + 14);
    while (true)
    {
        is.read(W_b, 64);
        if (is.eof())
            break;
        updateH(W);
        curr_size += 512;
    }

    // Add padding
    int last_read_size = is.gcount();
    curr_size += last_read_size * 8;
    W_b[last_read_size] = '\x80';
    if (last_read_size < 56)
    {
        for (size_t i = last_read_size + 1; i < 56; ++i)
            W_b[i] = '\x00';        
        *bit_sz_ptr = bswap_64(curr_size);
        updateH(W);
    }
    else 
    {
        for (size_t i = last_read_size + 1; i < 64; ++i)
            W_b[i] = '\x00'; 
        updateH(W);
        for (size_t i = 0; i < 56; ++i)
            W_b[i] = '\x00'; 
        *bit_sz_ptr = bswap_64(curr_size);
        updateH(W);
    }
    
    return &H;
}

void SHA256::updateH(uint32_t W[])
{
    // Prepare W
    for (size_t i = 0; i < 16; ++i)
        W[i] = bswap_32(W[i]);
    for (size_t i = 16; i < 64; ++i)
        W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15]) + W[i-16];
    
    // Init a to h
    uint32_t a = H[0];
    uint32_t b = H[1];
    uint32_t c = H[2];
    uint32_t d = H[3];
    uint32_t e = H[4];
    uint32_t f = H[5];
    uint32_t g = H[6];
    uint32_t h = H[7];

    // Main loop
    for (size_t i = 0; i < 64; ++i) {
        const uint32_t T1 = h + Sigma1(e) + Ch(e, f, g) + K[i] + W[i];
        const uint32_t T2 = Sigma0(a) + Maj(a, b, c);
        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;
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

const std::array<uint32_t, 64> SHA256::K = {
        0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL, 0x3956c25bUL, 0x59f111f1UL, 0x923f82a4UL, 0xab1c5ed5UL,
        0xd807aa98UL, 0x12835b01UL, 0x243185beUL, 0x550c7dc3UL, 0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL, 0xc19bf174UL,
        0xe49b69c1UL, 0xefbe4786UL, 0x0fc19dc6UL, 0x240ca1ccUL, 0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL,
        0x983e5152UL, 0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL, 0xc6e00bf3UL, 0xd5a79147UL, 0x06ca6351UL, 0x14292967UL,
        0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL, 0x53380d13UL, 0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL,
        0xa2bfe8a1UL, 0xa81a664bUL, 0xc24b8b70UL, 0xc76c51a3UL, 0xd192e819UL, 0xd6990624UL, 0xf40e3585UL, 0x106aa070UL,
        0x19a4c116UL, 0x1e376c08UL, 0x2748774cUL, 0x34b0bcb5UL, 0x391c0cb3UL, 0x4ed8aa4aUL, 0x5b9cca4fUL, 0x682e6ff3UL,
        0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL, 0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL
    };

const std::array<uint32_t, 8> SHA256::H0 = {
    0x6a09e667UL, 0xbb67ae85UL, 0x3c6ef372UL, 0xa54ff53aUL, 0x510e527fUL, 0x9b05688cUL, 0x1f83d9abUL, 0x5be0cd19UL
    };