; Coded by MMxM
; linux x86_64
; sys_fork() example
; [mmxm@hc0d3r asm]$ nasm -f elf64 -g fork.asm;ld -o fork fork.o
; [mmxm@hc0d3r asm]$ ./fork
; [*] parent process PID => 15709
; [+] sys_fork() ok ! PID => 15710


SYS_WRITE equ 1
SYS_GETPID equ 39
SYS_FORK equ 57
SYS_EXIT equ 60

STDOUT equ 1
STDERR equ 2

section .data
  fork_failed db '[-] sys_fork() failed',0xa
  ff_len equ $-fork_failed

  fork_success db '[+] sys_fork() ok ! '
  fs_len equ $-fork_success

  parent db '[*] parent process '
  p_len equ $-parent

  pid_r db 'PID => '
  pid_r_len equ $-pid_r

  br db 0xa

section .text
  global _start
_start:
  mov rax, SYS_FORK
  syscall

  cmp rax, 0
  jl fork_failed

  cmp rax, 0
  je fork_successfu

  cmp rax, 0
  jg parent_pid

parent_pid:

  mov rsi, parent
  mov rdx, p_len
  call write

  call getpid

  xor rdi, rdi
  call exit

fork_error:
  mov rdx, ff_len
  mov rsi, fork_failed

  call write_err

  mov rdi, 1
  call exit

fork_successfu:
  mov rdx, fs_len
  mov rsi, fork_success
  call write

  call getpid

  xor rdi, rdi
  call exit

write_err:
  mov rax, SYS_WRITE
  mov rdi, STDERR
  syscall
  ret

write:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  syscall
  ret

exit:
  mov rax, SYS_EXIT
  syscall

getpid:
  push rbp
  mov rbp, rsp

  mov rsi, pid_r
  mov rdx, pid_r_len
  call write

  mov rax, SYS_GETPID
  syscall

  mov rbx, 10
  xor rcx, rcx
  xor rdx, rdx

  L1:

    div rbx
    add rdx, '0'

    push rdx
    xor rdx, rdx
    add rcx, 8

    cmp rax, 0
  jg L1

  mov rsi, rsp
  mov rdx, rcx
  call write

  mov rsi, br
  mov rdx, 1
  call write

  mov rsp, rbp
  pop rbp

  ret
