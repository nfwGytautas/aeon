#include <aeon/Terminal.h>
#include <aeon/boot/GDT.h>
#include <libc/stdio.h>

extern int setupArch();

/* Kernel main needs to use C linkage */
extern "C" {

/**
 * @brief Entry function for aeon kernel
 */
void aeonMain() {
    aeon::Terminal::Initialize();

    aeon::InitializeGDT();

    printf("Main");
}

}
