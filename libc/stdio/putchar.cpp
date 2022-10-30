#include <stdio.h>

#if defined(__is_libk)
#include <aeon/Terminal.h>
#endif

int putchar(int ic) {
#if defined(__is_libk)
	char c = (char) ic;
	aeon::Terminal::Write(&c, sizeof(c));
#else
	// TODO: Implement stdio and the write system call.
#endif
	return ic;
}
