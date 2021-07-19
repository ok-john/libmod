#include <stdio.h>

// If you are a curious person then I invite you to
// build and execute this simple C application multiple times to receieve what will look to you as a new process id each execution.
// When infact this is /proc/sys/kernel/randomize_va_space randomizing userspaces view of the address space.
//
// I unadvise disabling this:
//
//      echo 0 > /proc/sys/kernel/randomize_va_space
//
// If you are a keen observer you may notice that 9 bytes of the 'randomized' address is constant across execution.
// This is your index into the page tables.

int main(void)
{
    printf("at %p", &main);
}
