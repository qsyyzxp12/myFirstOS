    .code16 
    .section .text
    .global _start

_start:
    # FAT12 file system format
    jmp       start_prog       # jmp instruction
    .byte     0x90
    .ascii    "ADRIAN  "       # OEM name (8 bytes)
    .word     512              # Bytes per sector
    .byte     1                # Sector per cluster
    .word     1                # Reserved sector count: should be 1 for FAT12
    .byte     2                # Number of file allocation tables.
    .word     224              # Maximum number of root directory entries.
    .word     2880             # Total sectors
    .byte     0xf0             # Media descriptor:
    .word     9                # Sectors per File Allocation Table
    .word     18               # Sectors per track
    .word     2                # Number of heads
    .long     0                # Count of hidden sectors
    .long     2880             # Total sectors: 18 (sectors per track) * 2 (heads) * 80 (sectors) = 2880
    .byte     0                # Physical driver number
    .byte     0                # Reserved
    .byte     0x29             # Extended boot signature
    .long     0x12345678       # Serial Number
    .ascii    "HELLO-OS   "    # Volume Label
    .ascii    "FAT12   "       # FAT file system type
    .fill     18, 1, 0         # fill 18 characters with zero

start_prog:
    movw    $0, %ax            # Initialize register
    movw    %ax, %ss
    ;movw    $0x7c00, %sp
    movw    %ax, %ds
    movw    %ax, %es
    movw    $msg, %si          # move the address of msg to SI

loop:
    movb    (%si), %al        # move the first character of msg to AL register
    addw    $1, %si
    cmpb    $0, %al
    je      fin
    movb    $0xe, %ah
    movw    $15, %bx
    int     $0x10             # write the specific character to console
    jmp     loop

fin:
# do nothing

msg:
    .ascii "Hello, World"
    .byte   0

    .org    0x1FE, 0x00       # fill the rest of characters with zero until the 254th character
# Boot sector signature
    .byte     0x55
    .byte     0xaa
