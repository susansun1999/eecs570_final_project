#include "sha.hh"
#include <string>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <chrono> 

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
//    printResult(SHA.Hash(is0));
    printResult(SHA.Hash(is1));
}
