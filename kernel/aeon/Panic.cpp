#include "aeon/Panic.h"
#include <libc/stdio.h>

namespace aeon {

void panic(const char* message) {
    // TODO: Implement normal panic
    printf(message);
}

}
