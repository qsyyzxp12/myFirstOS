	.code16
	.section .text
	.global _start
_start:
	# FAT12 file system format
	jmp	start_prog	# jmp instruction
	.byte	0x90
	.ascii	"Chih-An "	# OEM name (8 bytes)
	.word	0x0200		# Bytes per sector
	.byte	0x08		# Sector per cluster
	.word	0x0CA6		# Reserved sector count: should be 1 for FAT12
	.byte	0x02           	# Number of file allocatio
	.fill	4, 1, 0x00	
	.byte	0xF8
	.word	0x0000
	.word	0x003F
	.word	0x00ff
	.fill 	4, 1, 0x00
	.long	0x00E73040
	.long	0x000039ad
	.fill	4, 1, 0x00
	.long	0x00000002
	.word	0x0001		# Total sectors: 18 (sectors per track) * 2 (heads) * 80 (sectors) = 2880
	.word	0x0006		# Physical driver number
	.fill	12, 1, 0x00
	.byte	0x80		# Extended boot signature
	.byte	0x01
	.byte	0x29
	.long	0x9e4cbdce
	.ascii	"I'm fat32  "	# Volume Label
	.ascii	"FAT32   "	# FAT file system type
	.fill	18, 1, 0	# fill 18 characters with zero
start_prog:
	movw	$0, %ax
	movw	%ax, %ss
	movw 	$0x7c00, %sp
	movw 	%ax, %ds
	movw	%ax, %es
	movw	$msg, %si

readLoop:
	movb	$0x0e, %ah
	movb	(%si), %al
	cmpb	$0, %al
	je	fin
	int	$0x10
	addw	$1, %si
	jmp	readLoop

fin:
msg:
	.ascii "HELLO FAT32"
	.byte	0
	
	.org	0x1FE, 0x00
	.byte	0x55
	.byte	0xAA
	
