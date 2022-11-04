#include <aeon/Terminal.h>
#include <libc/stdio.h>

/* Kernel main needs to use C linkage */
extern "C" {

/**
 * @brief Early entry for aeon kernel (global constructors not setup yet)
 */
void aeonEarlyMain() {
    aeon::Terminal::Initialize();
    printf("Early main\n");
}

/**
 * @brief Entry function for aeon kernel
 */
void aeonMain() {
    printf("Main");
}
}
