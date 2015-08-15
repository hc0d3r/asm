; author -> mmxm
; program to print time, change GMT to your default TIME_ZONE
; $ nasm -f elf64 print_time.asm; ld -o print_time print_time.o
; $ ./print_time
; $ [13:17:10]

section .bss
  seconds resd 1
  minutes resd 1
  hours resd 1
  time_str resb 11

section .data
  LEAPOCH equ 951868800
  GMT equ -3

section .text
  global _start
_start:

  mov byte [time_str+0], '['
  mov byte [time_str+3], ':'
  mov byte [time_str+6], ':'
  mov byte [time_str+9], ']'
  mov byte [time_str+10], 0xa

  ;;; time

  mov rax, 201
  xor rdi, rdi

  syscall

  xor rdx, rdx

  ;;; http://git.musl-libc.org/cgit/musl/tree/src/time/__secs_to_tm.c

  sub rax, LEAPOCH
  mov rbx, 86400

  div rbx

  cmp rax, 0
  jg skip_add
  add rax, 86400

  skip_add:

  mov rax, rdx


  xor rdx, rdx
  mov rbx, 60
  div rbx


  mov rcx, rdx
  xor rdx, rdx

  mov rbx, 60
  div rbx

  add rax, 24
  add rax, GMT
  push rdx
  xor rdx, rdx
  mov rbx, 24
  div rbx
  mov rax, rdx
  pop rdx

;;; time_complete
  mov dword [hours], eax
  mov dword [minutes], edx
  mov dword [seconds], ecx

;;; time_to_str

  xor rdx, rdx
  mov rbx, 10

  mov eax, [dword hours]
  div ebx

  add al, '0'
  add dl, '0'

  mov [time_str+1], al
  mov [time_str+2], dl

  xor rdx, rdx
  mov eax, [dword minutes]
  div ebx

  add al, '0'
  add dl, '0'

  mov [time_str+4], al
  mov [time_str+5], dl

  xor rdx, rdx

  mov eax, [dword seconds]
  div ebx

  add al, '0'
  add dl, '0'

  mov [time_str+7], al
  mov [time_str+8], dl

;;; print

  mov rax, 1
  mov rdi, 1
  mov rsi, time_str
  mov rdx, 11
  syscall

;;; exit
  mov rax, 60
  xor rdi, rdi
  syscall
