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

    const std::chrono::time_point<std::chrono::steady_clock> start =
        std::chrono::steady_clock::now();
 
    const array<uint32_t, 8>* H = SHA.Hash(is1);

    const auto end = std::chrono::steady_clock::now();
 
    std::cout<< "Slow calculations took "<< std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() << "µs ≈ "
      << (end - start) / 1ms << "ms ≈ " // almost equivalent form of the above, but
      << (end - start) / 1s << "s.\n";  // using milliseconds and seconds accordingly

//	printResult(H);
}
