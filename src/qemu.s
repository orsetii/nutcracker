
section .text
global qemu_exit: function
; Exits QEMU via writing to the 'isa-debug-exit' port
qemu_exit:
    mov dx, 0xf4
    mov eax, 0x10
    out dx, eax
  
