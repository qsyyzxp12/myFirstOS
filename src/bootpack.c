#include<stdio.h>
void main()
{
	asm(
			"movb	$0x13, %al\n\t"
			"movb	$0x00, %ah\n\t"
			"int 	$0x10\n\t"
	
			"movb	$0x08, (0x0ff2)\n\t"
			"movw	$0x140, (0x0ff4)\n\t"
			"movw	$0xc8, (0x0ff6)\n\t"
			"movl	$0x000a0000, (0x0ff8)\n\t"

			"movb	$0x02, %ah\n\t"
			"int 	$0x16\n\t"
			"movb	%al, (0x0ff1)\n"
		"fin:\n\t"
			"jmp	fin"
	);
}
