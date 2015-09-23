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
	.word	0x0020		# Reserved sector count: should be 32 for FAT32
	.byte	0x02           	# Number of FAT
	.fill	4, 1, 0x00	# unused
	.byte	0xF8		# media descripter, 0xF8 means hard-disk
	.word	0x0000		# unused
	.word	0x003E		# Sector per Track
	.word	0x00EF		# Total heads
	.long	0x0000003F	# Number of hidden Sector，從0到DBR磁區數，DBR包涵跳轉指令，OEM代號，BPB，引導程序和结束標誌，共512bytes
	.long	0x00E73001	# Total sectors
	.long	0x000039b0	# Sector per FAT
	.word	0x0000		# Label
	.word	0x0000		# Version	
	.long	0x00000002	# Cluster No. of the Startof the Root Directory
	.word	0x0001		# Sector No. of the FileSystem Information
	.word	0x0006		# Sector No. of the BackupBoot Sector
	.fill	12, 1, 0x00	# unused
	.byte	0x80		# BIOS device
	.byte	0x00		# unused
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
fileSystem_Information_Sector:
	.long	0x41615252
	.fill	480, 1, 0x00
	.long	0x61417272
	.long	0x001CD797
	.long	0x00000002
	.fill	14, 1, 0x00
	.word	0xAA55

	.org	0xC00, 0x00
Backup_Boot_Sector:	
	# FAT32 file system format
	jmp	start_prog2	# jmp instruction
	.byte	0x90
	.ascii	"Chih-An "	# OEM name (8 bytes)
	.word	0x0200		# Bytes per sector
	.byte	0x08		# Sector per cluster
	.word	0x0020		# Reserved sector count: should be 32 for FAT32
	.byte	0x02           	# Number of FAT
	.fill	4, 1, 0x00	# unused
	.byte	0xF8		# media descripter, 0xF8 means hard-disk
	.word	0x0000		# unused
	.word	0x003E		# Sector per Track
	.word	0x00EF		# Total heads
	.long	0x0000003F	# Number of hidden Sector，從0到DBR磁區數，DBR包涵跳轉指令，OEM代號，BPB，引導程序和结束標誌，共512bytes
	.long	0x00E73001	# Total sectors
	.long	0x000039b0	# Sector per FAT
	.word	0x0000		# Label
	.word	0x0000		# Version	
	.long	0x00000002	# Cluster No. of the Startof the Root Directory
	.word	0x0001		# Sector No. of the FileSystem Information
	.word	0x0006		# Sector No. of the BackupBoot Sector
	.fill	12, 1, 0x00	# unused
	.byte	0x80		# BIOS device
	.byte	0x00		# unused
	.byte	0x29		# Extened boot signature = 0x29
	.long	0x9e4cbdce	# disk sequence
	.ascii	"I'm fat32  "	# Volume Label
	.ascii	"FAT32   "	# FAT file system type
	.fill	18, 1, 0	# fill 18 characters with zero
start_prog2:
	movw	$0, %ax
	movw	%ax, %ss
	movw 	$0x7c00, %sp
	movw 	%ax, %ds
	movw	%ax, %es
	movw	$msg2, %si

readLoop2:
	movb	$0x0e, %ah
	movb	(%si), %al
	cmpb	$0, %al
	je	fin2
	int	$0x10
	addw	$1, %si
	jmp	readLoop2

fin2:
	jmp	fin2
msg2:
	.ascii "HELLO FAT32"
	.byte	0
	
	.org	0xDFE, 0x00
	.byte	0x55
	.byte	0xAA

	.org 	0x4000, 0x00
FAT1:
	.long	0x0ffffff0
	.long	0x0fffffff

	.org	0x73A000, 0x00
FAT2:
	.long	0x0ffffff0
	.long	0x0fffffff
	
	.org	0xE70000, 0x00
first_cluster:
	.fill	20, 1, 0x20
	.byte	0x08, 0x00, 0x00, 0x2F, 0x9C, 0x31, 0x47
	.byte	0x31, 0x47, 0x00, 0x00, 0x2F, 0x9C, 0x31, 0x47
