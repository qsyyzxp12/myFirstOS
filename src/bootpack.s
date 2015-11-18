	.file	"bootpack.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
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
movb	$0xff, %al
	out	%al, $0x21
	nop
	out	%al, $0xa1
	cli
	call	waitkbdout
	movb	$0xd1, %al
	out	%al, $0x64
	call	waitkbdout
	movb	$0xdf, %al
	out	%al, $0x60
	call	waitkbdout
	lgdt	(GDTR0)
	movl	%cr0, %eax
	and	$0x7fffffff, %eax
	or		$0x00000001, %eax
	movl	%eax, %cr0
	jmp	pipelineflush
pipelineflush:
	movw	$0x08, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	movl	bootpack, %esi
	movl	BOTPAK, %edi
	movl	512*1024/4, %ecx
	call	memcpy
	movl	$0x7c00, %esi
	movl	DSKCAC, %edi
	movl	512/4, %ecx
	call	memcpy
	movl	DSKCAC0+512, %esi
	movl	DSKCAC0+512, %edi
	movl	$0x00, %ecx
	movb	(CYLS), %cl
	imul	512*18*2/4, %ecx
	subl	512/4, %ecx
	call	memcpy
	movl	BOTPAK, %ebx
	movl	16(%ebx), %ecx
	addl	$0x03, %ecx
	shr	$0x02, %ecx
	jz		skip
	movl	20(%ebx), %esi
	addl	%ebx, %esi
	movl	15(%ebx), %edi
	call	memcpy
	skip:
	movl	15(%ebx), %esp
	ljmp	$0x0000010, $0x0000001b
	waitkbdout:
	in		$0x64, %al
	and	$0x02, %al
	jnz	waitkbdout
	ret
	memcpy:
	movl	(%esi), %eax
	addl	$0x04, %esi
	movl	%eax, (%edi)
	addl	$0x04, %edi
	subl	$0x01, %ecx
	jnz	memcpy
	ret
	.align	16
	GDT0:
	.fill	8, 1, 0
	.word	0xffff, 0x0000, 0x9200, 0x00cf
	.word	0xffff, 0x0000, 0x9a28, 0x0047
	.word	0x0000
	GDTR0:
	.word	8*3-1
	.long	GDT0
	.align	16
	bootpack:
	fin:
	HLT
	jmp	fin
# 0 "" 2
#NO_APP
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.8.4-2ubuntu1~14.04) 4.8.4"
	.section	.note.GNU-stack,"",@progbits
