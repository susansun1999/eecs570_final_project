#pragma once
#include <iostream>
#include <array>
#include <cstdint>

class SHA256
{
    public:
    const std::array<uint32_t, 8>* Hash(std::istream& is);

    private:
    std::array<uint32_t, 8> H;
    
    static const std::array<uint32_t, 64> K;
    static const std::array<uint32_t, 8> H0;

    void updateH(uint32_t* W);

    uint32_t ROTR(uint32_t x, int n) const
    {
        return (x >> n) | (x << (32-n));
    }

    uint32_t Sigma0(uint32_t x) const
    {
        return ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22);
    }

    uint32_t Sigma1(uint32_t x) const
    {
        return ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25);
    }

    uint32_t sigma0(uint32_t x) const
    {
        return ROTR(x, 7) ^ ROTR(x, 18) ^ (x >> 3);
    }

    uint32_t sigma1(uint32_t x) const
    {
        return ROTR(x, 17) ^ ROTR(x, 19) ^ (x >> 10);
    }

    uint32_t Ch(uint32_t x, uint32_t y, uint32_t z) const
    {
        return (x & y) ^ (~x & z);
    }

    uint32_t Maj(uint32_t x, uint32_t y, uint32_t z) const
    {
        return (x & y) ^ (x & z) ^ (y & z);
    }
};