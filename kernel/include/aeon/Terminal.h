#pragma once

#include <stddef.h>

namespace aeon {

/**
 * Class used for controlling the terminal
 */
class Terminal final {
public:
    static void Initialize();
    static void PutChar(char c);
    static void Write(const char* data, size_t size);
    static void WriteString(const char* data);
};

} // namespace aeon
