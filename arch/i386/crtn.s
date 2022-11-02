.section .init
	/* gcc contents of crtend.o's .init section */
	popl %ebp
	ret

.section .fini
	/* gcc contents of crtend.o's .fini section */
	popl %ebp
	ret
