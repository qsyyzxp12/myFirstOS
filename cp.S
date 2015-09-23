	.code16
	.section .text
	.global _start
_start:
	# FAT32 file system format
	jmp	start_prog		# jmp instruction
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
	.fill	22, 1, 0	# fill 18 characters with zero

start_prog:
	movw	$0x820, %ax	# write data into address 0x82
	movw	%ax, %es
	movb 	$0x00, %ch	# cylinder no.0
	movb 	$0x00, %dh	# head	no.0
	movb	$0x02, %cl	# sector no.2

readloop:
	movw	$0x00, %si	# register for fail times

retry:
	movb	$0x02, %ah	# Ah=0x02:read
	movb	$0x01, %al	# one sector
	movw	$0x00, %bx
	movb	$0x00, %dl	# a disk
	int	$0x13
	jnc	next		# if success, jump to next
	addw	$0x01, %si	# si++
	cmpw	$5, %si		# if si >= 5
	jae	error		# jump to error
	movb	$0x00, %ah	
	movb	$0x00, %dl	# reset the disk no. 
	int 	$0x13
	jmp	retry

next:
	movw	%es, %ax	# address push 0x20
	addw	$0x20, %ax
	movw	%ax, %es
	addb	$0x01, %cl	# next sector
	
	movb	%cl, %bh	# extract the lowest 6 bit of %cl
	movw	$0x02, %ax
	shl	%ax, %bh
	shr	%ax, %bh

	cmpb	$62, %bh	# if bh(sector no.) <= 62
	jbe	readloop	# jump to readloop

	movw	$0x06, %ax	# let the lowest 6 bit of cl to be 1
	shr	%ax, %cl
	shl	%ax, %cl
	addb	$0x01, %cl

	addb	$0x01, %dh	# next head
	cmpb	$239, %dh	# if dh(head no.) < 239
	jb	readloop
	movb	$0, %dh

	cmpb	$0xff, %ch	# if ch(cylinder no.) <= 0xff
	jb	can_ch_add_1_or_not
	
	movb	$0x00, %ch
	addb	$0x40, %cl
	jmp 	readloop

can_ch_add_1_or_not:
	cmpb	$253, %ch
	je	check_cl_highest_two_bit

ch_add_1:	
	addb	$0x01, %ch
	jmp 	readloop

checl_cl_highest_two_bit:	
	movb	%cl, %bh
	movw	$0x06, %ax
	shr	%ax, %bh
	cmpb	%0x03, %bh
	je	fin
	jmp	ch_add_1

fin:
	jmp	fin
	
error:
	movw	$0, %ax
	movw	%ax, %ss
	movw	$0x7c00, %sp
	movw	%ax, %ds
	movw	%ax, %es
	movw	$error_msg, %si	

print_error_msg:
	movb	$0x0e, %ah
	movb	(%si), %al
	cmpb	$0, %al
	je	fin
	int	$0x10
	addw	$1, %si
	jmp	print_error_msg
		
error_msg:
	.ascii "Load error"
	.byte	0

	.org	0x1FE, 0x00
	.byte	0x55
	.byte	0xAA

