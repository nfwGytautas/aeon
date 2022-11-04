/**
 * @file stdio.cpp
 * @brief File contains implementation for stdio.h
 * @author nfwGytautas
 * @date 11/2/22
 */

#include <libc/stdio.h>
#include <libc/string.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>

#ifdef __AEON_LIBK
#include <aeon/Terminal.h>
#endif

static bool print(const char* data, size_t length) {
    const unsigned char* bytes = (const unsigned char*)data;
    for (size_t i = 0; i < length; i++)
        if (putchar(bytes[i]) == EOF)
            return false;
    return true;
}

static int num_digits(int number) {
    int count = 0;
    while (number != 0) {
        number = number / 10;
        count++;
    }
    return count;
}

char* itoa(int n, int base) {
    static char buffer[50];
    int i = 0;

    bool isNeg = n < 0;

    unsigned int n1 = isNeg ? -n : n;

    while (n1 != 0) {
        buffer[i++] = n1 % 10 + '0';
        n1 = n1 / 10;
    }

    if (isNeg)
        buffer[i++] = '-';

    buffer[i] = '\0';

    for (int t = 0; t < i / 2; t++) {
        buffer[t] ^= buffer[i - t - 1];
        buffer[i - t - 1] ^= buffer[t];
        buffer[t] ^= buffer[i - t - 1];
    }

    if (n == 0) {
        buffer[0] = '0';
        buffer[1] = '\0';
    }

    return buffer;
}

int printf(const char* format, ...) {
    va_list parameters;
    va_start(parameters, format);

    int written = 0;

    while (*format != '\0') {
        size_t maxrem = INT_MAX - written;

        if (format[0] != '%' || format[1] == '%') {
            if (format[0] == '%')
                format++;
            size_t amount = 1;
            while (format[amount] && format[amount] != '%')
                amount++;
            if (maxrem < amount) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(format, amount))
                return -1;
            format += amount;
            written += amount;
            continue;
        }

        const char* format_begun_at = format++;

        if (*format == 'c') {
            format++;
            char c = (char)va_arg(parameters, int /* char promotes to int */);
            if (!maxrem) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(&c, sizeof(c)))
                return -1;
            written++;
        } else if (*format == 's') {
            format++;
            const char* str = va_arg(parameters, const char*);
            size_t len = strlen(str);
            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(str, len))
                return -1;
            written += len;
        } else if (*format == 'l' && *(format + 1) == 'd') {
            int val = va_arg(parameters, int);
            int len = num_digits(val);
            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }

            if (val == 0)
            {
                len++;
            }

            char* values = itoa(val, 10);
            if (!print(values, len))
                return -1;
            written += len;
            format += 2;
        } else {
            format = format_begun_at;
            size_t len = strlen(format);
            if (maxrem < len) {
                // TODO: Set errno to EOVERFLOW.
                return -1;
            }
            if (!print(format, len))
                return -1;
            written += len;
            format += len;
        }
    }

    va_end(parameters);
    return written;
}

int putchar(int ic) {
#ifdef __AEON_LIBK
    char c = (char)ic;
    aeon::Terminal::Write(&c, sizeof(c));
#else
    // TODO: Implement stdio and the write system call.
#endif
    return ic;
}

int puts(const char* string) {
    return printf("%s\n", string);
}
