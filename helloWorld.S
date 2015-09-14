    .code16
    .section .text
    .global _start

_start:
    movw    $0, %ax            # Initialize register
    movw    %ax, %ss
    movw    %ax, %ds
    movw    %ax, %es
    movw    $msg, %si          # move the address of msg to SI

loop:
    movb    $0xe, %ah
    movb    (%si), %al        # move the first character of msg to AL register
    cmpb    $0, %al
    je      fin
    int     $0x10             # write the specific character to console
    addw    $1, %si
    jmp     loop

fin:
# do nothing

msg:
    .ascii "Hello, World!"
    .byte   0
    .org    0x1FE, 0x00       # fill the rest of characters with zero until the 254th character

# Boot sector signature
    .byte     0x55
    .byte     0xaa

