; author: mmxm
; linux x86_64
; sys_uname example
; [mmxm@hc0d3r asm]$ nasm -f elf64 uname.asm;ld -o uname uname.o
; [mmxm@hc0d3r asm]$ ./uname
; Linux hc0d3r 4.0.8-200.fc21.x86_64 #1 SMP Fri Jul 10 21:09:54 UTC 2015 x86_64
; [mmxm@hc0d3r asm]$ uname -a
; Linux hc0d3r 4.0.8-200.fc21.x86_64 #1 SMP Fri Jul 10 21:09:54 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux

SYS_WRITE equ 1
SYS_UNAME equ 63
SYS_EXIT equ 60
STDOUT equ 1
UTSNAME_SIZE equ 65

section .bss
  uname_res resb UTSNAME_SIZE*5

section .data
  space db ' '
  break_line db 0xa

section .text
  global _start

_start:
  mov rax, SYS_UNAME
  mov rdi, uname_res
  syscall

  mov rdi, 1
  cmp rax, 0
  jne exit

  call print_all_utsname

  xor rdi, rdi
  call exit

print_all_utsname:
  xor rcx, rcx
  xor rbx, rbx
  mov cl, 5

  mov rdi, STDOUT

  L1:
    push rcx

    mov rax, SYS_WRITE
    mov rdx, UTSNAME_SIZE
    lea rsi, [uname_res + rbx]
    add bx, UTSNAME_SIZE
    syscall

    mov rax, SYS_WRITE
    mov rsi, space
    mov rdx, 1
    syscall

    pop rcx

  loop L1

  mov rax, SYS_WRITE
  mov rsi, break_line
  mov rdx, 1
  syscall

  ret

exit:
  mov rax, SYS_EXIT
  syscall
