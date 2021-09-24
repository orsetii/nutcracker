
extern qemu_exit
extern kmain;

section .text
global boot1: function
boot1:
    call kmain
    call qemu_exit