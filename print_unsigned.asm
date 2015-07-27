; Coded by MMxM
; function to print unsigned integers (uint64_t) at decimal notation
; [mmxm@hc0d3r asm]$ nasm -f elf64 print_unsigned.asm
; [mmxm@hc0d3r asm]$ ld -o print_unsigned print_unsigned.o
; [mmxm@hc0d3r asm]$ ./print_unsigned
; 31337
; 18446744073709551615
; 123456789
; 9784515687
; 0
; 5187
; [mmxm@hc0d3r asm]$ ./print_unsigned
; ...
; 5188


SYS_WRITE equ 1
SYS_EXIT equ 60
SYS_GETPID equ 39
STDOUT equ 1

section .data
	break_lin db 0xa

section .text
	global _start
_start:
	mov rbp, rsp

	mov rax, 31337
	call print_uint
	call break_line

	mov rax, 0xffffffffffffffff
	call print_uint
	call break_line

	mov rax, 123456789
	call print_uint
	call break_line

	mov rax, 9784515687
	call print_uint
	call break_line

	xor rax, rax
	call print_uint
	call break_line

	mov rax, SYS_GETPID
	syscall
	call print_uint
	call break_line

	xor rdi, rdi
	mov rax, SYS_EXIT
	syscall

break_line:

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, break_lin
	mov rdx, 1

	syscall

	ret



print_uint:
	push rbp
	mov rbp, rsp

	sub rsp, 20
	mov rbx, 10

	mov rcx, 19

	lea rsi, [rbp-20]


	uint_L1:

		xor rdx, rdx

		div rbx ; rax = rax/10
		add rdx, '0' ; rdx = rax%10, rdx += '0'

		mov byte [rsi+rcx], dl ; rsi[rcx] = dl
		dec rcx ; rcx-- , como é LIFO, começa a gravar do final

		cmp rax, 0

	jg uint_L1 ; do { ... } while(rax > 0)


	lea rsi, [ rsi + rcx + 1 ] ; carrega o endereço onde a string termina, para não printar bytes nulos

	mov r9, 19
	sub r9, rcx ; r9 = 20 - rcx, para saber o tamanho da string, e não printar bytes nulos

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rdx, r9

	syscall

	mov rsp, rbp
	pop rbp

	ret
