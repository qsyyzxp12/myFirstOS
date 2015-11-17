	.file	"bootpack.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
#APP
# 4 "bootpack.c" 1
	movb	$0x13, %al
	movb	$0x00, %ah
	int 	$0x10
	movb	$0x08, (0x0ff2)
	movw	$0x140, (0x0ff4)
	movw	$0xc8, (0x0ff6)
	movl	$0x000a0000, (0x0ff8)
	movb	$0x02, %ah
	int 	$0x16
	movb	%al, (0x0ff1)
fin:
	jmp	fin
# 0 "" 2
#NO_APP
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.8.4-2ubuntu1~14.04) 4.8.4"
	.section	.note.GNU-stack,"",@progbits
