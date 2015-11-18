

.equ 	BOTPAK, 0x00280000
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
		int		$0x10

		movb	$0x08, (VMODE)
		movw	$0x140, (SCRNX)
		movw	$0xc8, (SCRNY)
		movl	$0x000a0000, (VRAM)

		movb	$0x02, %ah
		int		$0x16
		movb	%al, (LEDS)

		movb	$0xff, %al			#MOV		AL,0xff
		out		%al, $0x21			#OUT		0x21,AL, 將AL或AX的內容輸出到0x21這個I/O port中
		nop							#no operation
		out		%al, $0xa1			#OUT		0xa1,AL

		cli

		call	waitkbdout
		movb	$0xd1, %al			#MOV		AL,0xd1
		out		%al, $0x64			#OUT		0x64,AL
		call	waitkbdout
		movb	$0xdf, %al			#MOV		AL,0xdf
		out		%al, $0x60			#OUT		0x60,AL
		call	waitkbdout

#[INSTRSET "i486p"]

		lgdt	(GDTR0)				#LGDT		[GDTR0]
		movl	%cr0, %eax			#MOV		EAX,CR0
		and		$0x7fffffff, %eax	#AND		EAX,0x7fffffff
		or		$0x00000001, %eax	#OR			EAX,0x00000001
		movl	%eax, %cr0			#MOV		CR0,EAX
		jmp		pipelineflush
pipelineflush:
		movw	$0x08, %ax			#MOV		AX,1*8
		movw	%ax, %ds			#MOV		DS,AX
		movw	%ax, %es			#MOV		ES,AX
		movw	%ax, %fs			#MOV		FS,AX
		movw	%ax, %gs			#MOV		GS,AX
		movw	%ax, %ss			#MOV		SS,AX

		movl	bootpack, %esi		#MOV		ESI,bootpack
		movl	BOTPAK, %edi		#MOV		EDI,BOTPAK
		movl	512*1024/4, %ecx	#MOV		ECX,512*1024/4
		call	memcpy

		movl	$0x7c00, %esi		#MOV		ESI,0x7c00
		movl	DSKCAC, %edi		#MOV		EDI,DSKCAC
		movl	512/4, %ecx			#MOV		ECX,512/4
		call	memcpy

		movl	DSKCAC0+512, %esi	#MOV		ESI,DSKCAC0+512
		movl	DSKCAC0+512, %edi	#MOV		EDI,DSKCAC+512
		movl	$0x00, %ecx			#MOV		ECX,0
		movb	(CYLS), %cl			#MOV		CL,BYTE [CYLS]
		imul	512*18*2/4, %ecx	#IMUL		ECX,512*18*2/4
		subl	512/4, %ecx			#SUB		ECX,512/4
		call	memcpy

		movl	BOTPAK, %ebx		#MOV		EBX,BOTPAK
		movl	16(%ebx), %ecx		#MOV		ECX,[EBX+16]
		addl	$0x03, %ecx			#ADD		ECX,3
		shr		$0x02, %ecx			#SHR		ECX,2
		jz		skip
		movl	20(%ebx), %esi		#MOV		ESI,[EBX+20]
		addl	%ebx, %esi			#ADD		ESI,EBX
		movl	15(%ebx), %edi		#MOV		EDI,[EBX+12]
		call	memcpy
skip:
		movl	15(%ebx), %esp		#MOV		ESP,[EBX+12]
		ljmp	$0x0000010, $0x0000001b#JMP		DWORD 2*8:0x0000001b

waitkbdout:
		in		$0x64, %al			#IN			 AL,0x64
		and		$0x02, %al			#AND		 AL,0x02
		jnz		waitkbdout
		ret

memcpy:
		movl	(%esi), %eax		#MOV		EAX,[ESI]
		addl	$0x04, %esi			#ADD		ESI,4
		movl	%eax, (%edi)		#MOV		[EDI],EAX
		addl	$0x04, %edi			#ADD		EDI,4
		subl	$0x01, %ecx			#SUB		ECX,1
		jnz		memcpy
		ret

		.align	16					#ALIGNB	16
GDT0:
		.fill	8, 1, 0				#RESB	8
		.word	0xffff, 0x0000, 0x9200, 0x00cf	#DW		0xffff,0x0000,0x9200,0x00cf
		.word	0xffff, 0x0000, 0x9a28, 0x0047	#DW		0xffff,0x0000,0x9a28,0x0047
		.word	0x0000							#DW		0
GDTR0:
		.word	8*3-1							#DW		8*3-1
		.long	GDT0							#DD		GDT0

		.align	16								#ALIGNB	16
bootpack:
