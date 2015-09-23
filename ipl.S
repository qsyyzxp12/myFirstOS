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
	.fill	22, 1, 0	# fill 18 characters with zero

start_prog:
	movw	$0x820, %ax	# write data into address 0x8200
	movw	%ax, %es
	movb 	$0x01, %ch	# cylinder no.2
	movb 	$0xEE, %dh	# head	no.289
	movb	$0x03, %cl	# sector no.3

readloop:
	movw	$0x00, %si	# register for fail times

retry:
	movb	$0x02, %ah	# Ah=0x02:read
	movb	$0x01, %al	# one sector
	movw	$0x00, %bx
	movb	$0x00, %dl	# a disk
	int	$0x13
	jnc	success		# if success, jump to success
	addw	$0x01, %si	# si++
	cmpw	$5, %si		# if si >= 5
	jae	error		# jump to error
	movb	$0x00, %ah	
	movb	$0x00, %dl	# reset the disk no. 
	int 	$0x13
	jmp	retry

next_sector:
	movw	%es, %ax	# address push 0x20
	addw	$0x20, %ax
	movw	%ax, %es

	cmpb	$0x12, %cl
	je	check_read_512_sector_or_not

keep_reading:
	addb	$0x01, %cl	# next sector
	cmpb	$0x3E, %cl	# if sector no. <= 62
	jbe	readloop	# jump to readloop
	movb	$0x01, %cl
	
	addb	$0x01, %dh	# next head
	cmpb	$0xEF, %dh	# if dh(head no.) < 239
	jb	readloop
	movb	$0x00, %dh

	addb	$0x01, %ch
	jb	readloop

check_read_512_sector_or_not:
	cmpb	$0x07, %dh
	je	0x8200
	jmp	keep_reading

fin:
	jmp	fin

success:
#	cmpb	$0x07, %dh
#	jne	next_sector

	movw	$0x00, %ax
	movw	%ax, %ss
	movw	$0x7c00, %sp
	movw	%ax, %ds
	movw	$success_msg, %si
	
print_success_msg:
	movb	$0x0e, %ah
	movb	(%si), %al
	cmpb	$0, %al
	je	next_sector
	int	$0x10
	addw	$1, %si
	jmp	print_success_msg

success_msg:
	.ascii "1"
	.byte	0

error:
	movw	$0x00, %ax
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

