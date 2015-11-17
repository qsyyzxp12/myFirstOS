	.file	"bootpack.c"
	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
.L2:
	jmp	.L2
