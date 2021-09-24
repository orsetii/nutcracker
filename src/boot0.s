MBALIGN  equ  1 << 0           
MEMINFO  equ  1 << 1            
FLAGS    equ  MBALIGN | MEMINFO 
MAGIC    equ  0x1BADB002        
CHECKSUM equ -(MAGIC + FLAGS)   
 
; Section for the multiboot
section .multiboot
align 4
	dd MAGIC
	dd FLAGS
	dd CHECKSUM
 
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


