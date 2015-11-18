#include<stdio.h>
void main()
{
	asm(
			".equ	BOTPAK, 0x00280000\n\t"
			".equ	DSKCAC, 0x00100000\n\t"
			".equ	DSKCAC0, 0x00008000\n\t"
			".equ	CYLS, 0x0ff0\n\t"
			
			".equ	LEDS, 0x0ff1\n\t"	
			".equ	VMODE, 0x0ff2\n\t"		//與色彩有關的資訊，表示顏色所會用到的位元數
			".equ	SCRNX, 0x0ff4\n\t"		//X方向的解析度
			".equ	SCRNY, 0x0ff6\n\t"		//Y方向的解析度
			".equ	VRAM, 0x0ff8\n\t"		//圖形緩衝區的開始位置

			"movb	$0x13, %al\n\t"			//VGA圖形、320*200*8 bit色彩
			"movb	$0x00, %ah\n\t"
			"int 	$0x10\n\t"
	
			"movb	$0x08, (VMODE)\n\t"		//紀錄畫面模式
			"movw	$0x140, (SCRNX)\n\t"
			"movw	$0xc8, (SCRNY)\n\t"
			"movl	$0x000a0000, (VRAM)\n\t"

			//從BIOS告知鍵盤的LED狀態
			"movb	$0x02, %ah\n\t"
			"int 	$0x16\n\t"				//keyboard BIOS
			"movb	%al, (LEDS)\n"
/*
			"movb	$0xff, %al\n\t"			//MOV		AL,0xff
			"out	%al, $0x21\n\t"			//OUT		0x21,AL, 將AL或AX的內容輸出到0x21這個I/O port中
			"nop\n\t"						//no operation
			"out	%al, $0xa1\n\t"			//OUT		0xa1,AL
			
			"cli\n\t"

			"call	waitkbdout\n\t"
			"movb	$0xd1, %al\n\t"			//MOV		AL,0xd1
			"out	%al, $0x64\n\t"			//OUT		0x64,AL
			"call	waitkbdout\n\t"
			"movb	$0xdf, %al\n\t"			//MOV		AL,0xdf
			"out	%al, $0x60\n\t"			//OUT		0x60,AL
			"call	waitkbdout\n\t"

//[INSTRSET "i486p"]

			"lgdt	(GDTR0)\n\t"			//LGDT		[GDTR0]
			"movl	%cr0, %eax\n\t"			//MOV		EAX,CR0
			"and	$0x7fffffff, %eax\n\t"	//AND		EAX,0x7fffffff
			"or		$0x00000001, %eax\n\t"	//OR		EAX,0x00000001
			"movl	%eax, %cr0\n\t"			//MOV		CR0,EAX
			"jmp	pipelineflush\n"

		"pipelineflush:\n\t"
			"movw	$0x08, %ax\n\t"			//MOV		AX,1*8
			"movw	%ax, %ds\n\t"			//MOV		DS,AX
			"movw	%ax, %es\n\t"			//MOV		ES,AX
			"movw	%ax, %fs\n\t"			//MOV		FS,AX
			"movw	%ax, %gs\n\t"			//MOV		GS,AX
			"movw	%ax, %ss\n\t"			//MOV		SS,AX

			"movl	bootpack, %esi\n\t"		//MOV		ESI,bootpack
			"movl	BOTPAK, %edi\n\t"		//MOV		EDI,BOTPAK
			"movl	512*1024/4, %ecx\n\t"	//MOV		ECX,512*1024/4
			"call	memcpy\n\t"

			"movl	$0x7c00, %esi\n\t"		//MOV		ESI,0x7c00
			"movl	DSKCAC, %edi\n\t"		//MOV		EDI,DSKCAC
			"movl	512/4, %ecx\n\t"		//MOV		ECX,512/4
			"call	memcpy\n\t"

			"movl	DSKCAC0+512, %esi\n\t"	//MOV		ESI,DSKCAC0+512
			"movl	DSKCAC0+512, %edi\n\t"	//MOV		EDI,DSKCAC+512
			"movl	$0x00, %ecx\n\t"		//MOV		ECX,0
			"movb	(CYLS), %cl\n\t"		//MOV		CL,BYTE [CYLS]
			"imul	512*18*2/4, %ecx\n\t"	//IMUL		ECX,512*18*2/4
			"subl	512/4, %ecx\n\t"		//SUB		ECX,512/4
			"call	memcpy\n\t"

			"movl	BOTPAK, %ebx\n\t"		//MOV		EBX,BOTPAK
			"movl	16(%ebx), %ecx\n\t"		//MOV		ECX,[EBX+16]
			"addl	$0x03, %ecx\n\t"		//ADD		ECX,3
			"shr	$0x02, %ecx\n\t"		//SHR		ECX,2
			"jz		skip\n\t"
			"movl	20(%ebx), %esi\n\t"		//MOV		ESI,[EBX+20]
			"addl	%ebx, %esi\n\t"			//ADD		ESI,EBX
			"movl	15(%ebx), %edi\n\t"		//MOV		EDI,[EBX+12]
			"call	memcpy\n\t"

		"skip:\n\t"
			"movl	15(%ebx), %esp\n\t"		//MOV		ESP,[EBX+12]
			"ljmp	$0x0000010, $0x0000001b\n\t"//JMP		DWORD 2*8:0x0000001b

		"waitkbdout:\n\t"
			"in		$0x64, %al\n\t"			//IN		AL,0x64
			"and	$0x02, %al\n\t"			//AND		AL,0x02
			"jnz	waitkbdout\n\t"
			"ret\n\t"
	
		"memcpy:\n\t"
			"movl	(%esi), %eax\n\t"		//MOV		EAX,[ESI]
			"addl	$0x04, %esi\n\t"		//ADD		ESI,4
			"movl	%eax, (%edi)\n\t"		//MOV		[EDI],EAX
			"addl	$0x04, %edi\n\t"		//ADD		EDI,4
			"subl	$0x01, %ecx\n\t"		//SUB		ECX,1
			"jnz	memcpy\n\t"
			"ret\n\t"

			".align	16\n\t"					//ALIGNB	16
		"GDT0:\n\t"
			".fill	8, 1, 0\n\t"			//RESB	8
			".word	0xffff, 0x0000, 0x9200, 0x00cf\n\t"	//DW		0xffff,0x0000,0x9200,0x00cf
			".word	0xffff, 0x0000, 0x9a28, 0x0047\n\t"	//DW		0xffff,0x0000,0x9a28,0x0047
			".word	0x0000\n\t"							//DW		0
	
		"GDTR0:\n\t"
			".word	8*3-1\n\t"							//DW		8*3-1
			".long	GDT0\n\t"							//DD		GDT0

			".align	16\n\t"								//ALIGNB	16

		"bootpack:\n\t"*/
		"fin:\n\t"
				//"HLT\n\t"
				"jmp	fin"
	);
}
