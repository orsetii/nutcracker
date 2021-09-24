extern kmain;

section .text
global boot1: function
boot1:
    call kmain
    call qemu_exit
    ret


global qemu_exit: function
; Exits QEMU via writing to the 'isa-debug-exit' port
qemu_exit:
    mov dx, 0xf4
    mov eax, 0x10
    out dx, eax
    ret
  
