#include <aeon/Panic.h>
#include <libc/stdlib.h>
#include <stdint.h>

// Stack guard variable
// TODO: Randomize this value
constexpr uintptr_t STACK_CHK_GUARD = 0xE2DEE396;

extern "C" {

uintptr_t __stack_chk_guard = STACK_CHK_GUARD;

__attribute__((noreturn)) void __stack_chk_fail() {
#if __STDC_HOSTED__
    abort();
#elif __AEON_LIBK
    aeon::panic("Stack smashing detected");
#endif
}
}
