#include <aeon/Terminal.h>
#include <stdio.h>

/* Kernel main needs to use C linkage */
extern "C" {
/**
 * Entry function for aeon kernel
 */
void kernel_main() {
    aeon::Terminal::Initialize();
    printf("Hello, World!\n");
}
}
