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
	.equ	BOTPAK, 0x00280000
	.equ	DSKCAC, 0x00100000
	.equ	DSKCAC0, 0x00008000
	.equ	CYLS, 0x0ff0
	.equ	LEDS, 0x0ff1
	.equ	VMODE, 0x0ff2
	.equ	SCRNX, 0x0ff4
	.equ	SCRNY, 0x0ff6
	.equ	VRAM, 0x0ff8
	movb	$0x13, %al
	movb	$0x00, %ah
	int 	$0x10
	movb	$0x08, (VMODE)
	movw	$0x140, (SCRNX)
	movw	$0xc8, (SCRNY)
	movl	$0x000a0000, (VRAM)
	movb	$0x02, %ah
	int 	$0x16
	movb	%al, (LEDS)
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
