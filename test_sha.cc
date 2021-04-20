#include "sha.hh"
#include <string>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <chrono> 
#include <sys/time.h>

using namespace std;
using namespace std::chrono; 


void printResult(const array<uint32_t, 8>* H)
{
    for (int i = 0; i < 8; ++i)
    {
        cout << hex << setw(8) << setfill('0') << (*H)[i] << " ";
    }
    cout << endl;
}

int main()
{
//    istringstream is0("abc");
    ifstream is1("sha.js");
	SHA256 SHA; 
 /* get start timestamp */
  struct timeval tv;
  gettimeofday(&tv,NULL);
  uint64_t start = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
//    printResult(SHA.Hash(is0));
const array<uint32_t, 8>* H = SHA.Hash(is1);
/* get elapsed time */
 gettimeofday(&tv,NULL);
 uint64_t end = tv.tv_sec*(uint64_t)1000000+tv.tv_usec;
 uint64_t elapsed = end - start;

 printf("@@@ Elapsed time (usec): %lld\n", elapsed);
	printResult(H);
}
