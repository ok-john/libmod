
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <sys/resource.h>
#include <sys/mman.h>
#include <sys/uio.h>
#include <linux/fs.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <sched.h>


using namespace std;

// The following constants define a filestructure relative
// to the compiled binary
//
//      VTAG/   (version tag)
//          MVAR    (major version)
//          MNOR    (minor version)
//          RLSE    (release)
//      
//  this filestructure gets concatinated and used for git versioning into
//  the following format
//  
//      vMVAR.MNOR.RLSE
//  

#define VTAG ".tag";
#define MVAR "MVAR";
#define MNOR "MNOR";
#define RLSE "RLSE";

int main() {
    wstring wordLine;
    strcat(VTAG, "/");
    wifstream myfileRead(L"TEST.TXT");
    if (myfileRead.is_open()) {
        while (getline(myfileRead, wordLine)) {
            wcout << wordLine << endl;
        }
    }

    _getch();
    return 0;
}