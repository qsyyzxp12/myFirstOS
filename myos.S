	.code16
	.section .text
	.global _start
_start:
	# FAT32 file system format
	jmp	start_prog	# jmp instruction
	.byte	0x90
	.ascii	"Chih-An "	# OEM name (8 bytes)
	.word	0x0200		# Bytes per sector
	.byte	0x08		# Sector per cluster
	.word	0x0CA6		# Reserved sector count: should be 1 for FAT12
	.byte	0x02           	# Number of FAT
	.fill	4, 1, 0x00	# unused
	.byte	0xF8		# media descripter, 0xF8 means hard-disk
	.word	0x0000		# unused
	.word	0x003F		# Sector per Cylinberd
	.word	0x00FF		# Total heads
	.fill 	4, 1, 0x00	# 隱藏磁區，從0到DBR磁區數，DBR包涵跳轉指令，OEM代號，BPB，引導程序和结束標誌，共512bytes
	.long	0x00E73040	# Total sectors
	.long	0x000039ad	# Sector per FAT
	.word	0x0000		# Label
	.word	0x0000		# Version	
	.long	0x00000002	# 根目錄在DATA區的起始簇位置
	.word	0x0001		# 檔案系統信息磁區號
	.word	0x0006		# 備份引導磁區號
	.fill	12, 1, 0x00	# unused
	.byte	0x80		# BIOS device
	.byte	0x01		# unused
	.byte	0x29		# Extened boot signature = 0x29
	.long	0x9e4cbdce	# disk sequence
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
	jmp	fin
msg:
	.ascii "HELLO FAT32"
	.byte	0
	
	.org	0x1FE, 0x00
	.byte	0x55
	.byte	0xAA
	
