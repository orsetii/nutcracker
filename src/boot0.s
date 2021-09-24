; Section for stack
section .bss
align 16
stack_bottom:
resb 16384 ; 16 KiB
stack_top:

; Extern some functions we call in _start
extern boot1


section .text
global _start: function (_start.end - _start)
_start:

  ; Disable interrupts
  cli



  mov esp, stack_top




  call boot1

  cli
.hang:	hlt
  jmp .hang
.end:


