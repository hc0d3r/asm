; coder -> mmxm
; rc4 crypt (linux x86)
; $ cat /etc/passwd | ./rc4-encode secret > /tmp/test
; $ cat /tmp/test | ./rc4-encode secret > /tmp/passwd
; $ md5sum /etc/passwd /tmp/passwd
; 2fea0a28658fef02f397309ccb4892de  /etc/passwd
; 2fea0a28658fef02f397309ccb4892de  /tmp/passwd


sys_exit equ 1
sys_read equ 3
sys_write equ 4

stdout equ 1

section .rodata
	help_banner db	'Usage examples:',0xa,0xa
		db	'cat file | rc4 [key]',0xa
		db	'echo -n encode | rc4 [key]',0xa,
		db	'echo -n decode | rc4 [key]',0xa
	help_banner_len equ $-help_banner

section .text
	global _start

_start:
	mov ebp, esp
	xor byte [ebp], 2
	jne help

	sub esp, 268; 

	mov edi, [ebp+8]
	call strlen

	push ecx
	mov edi, [ebp+8]
	lea eax, [ebp-268]
	call ksa

	push eax
	call prga

	xor ebx, ebx
	jmp exit


ksa:
	push ebp
	mov ebp, esp

	sub esp, 8
	
	xor cl, cl
	xor bl, bl
	xor edx, edx

	.loop:
		mov byte [eax+ecx], cl
		inc cl
	jnz .loop

	xor cl, cl

	.loop2:
		add bl, [eax+ecx]
		add bl, [edi+edx]
		inc edx
		cmp edx, [ebp+8]
		jne $+4
		xor edx, edx


		mov dword [ebp-4], edx

		mov dl, [eax+ebx]
		mov byte [ebp-8], dl

		mov dl, [eax+ecx]
		mov byte [eax+ebx], dl


		mov dl, [ebp-8]
		mov byte [eax+ecx], dl

		mov edx, [ebp-4]

		inc cl
	jnz .loop2


	leave
	ret
prga:
	push ebp
	mov ebp, esp

	sub esp, 2072

	mov dword [ebp-4], 0 ; j
	mov dword [ebp-8], 0 ; i
	mov dword [ebp-12], 0 ; number of bytes read
	lea ecx, [ebp-1048]
	mov dword [ebp-20], ecx

	.loop:

	mov dword [ebp-24], 0

	mov eax, sys_read
	xor ebx, ebx
	mov ecx, [ebp-20]
	mov edx, 1024

	int 0x80

	cmp eax, 0
	jle .endloop

	mov esi, ecx
	mov dword [ebp-12], eax
	mov ecx, [ebp-4]
	mov edx, [ebp-8]

	.stringloop:

	; i = (i+1)%256

	inc dl

	; j = (j+s[i])%256

	mov eax, [ebp+8]
	add cl, [eax+edx]

	mov dword [ebp-4], ecx
	mov dword [ebp-8], edx

	; swap

	mov bl, [eax+ecx]
	mov byte [ebp-16], bl

	mov bl, [eax+edx]
	mov [eax+ecx], bl

	mov bl, [ebp-16]
	mov [eax+edx], bl


	; enc_byte = s[(s[i]+s[j])%256] ^ c

	add bl, [eax+ecx]
	mov bl, [eax+ebx]


	mov eax, [ebp-24]
	xor bl, [esi+eax]

	lea edi, [ebp-2072]
	mov [edi+eax], bl

	inc eax
	mov dword [ebp-24], eax

	cmp eax, [ebp-12]
	jne .stringloop

	; print 

	mov eax, sys_write
	mov ebx, stdout
	lea ecx, [ebp-2072]
	mov edx, [ebp-12]

	int 0x80

	jmp .loop

	.endloop:

	leave
	ret



strlen:

	mov ecx, 0xffffffff
	xor eax, eax


	repne scasb
	inc ecx
	not ecx

	ret




help:
	mov eax, sys_write
	mov ebx, stdout
	mov ecx, help_banner
	mov edx, help_banner_len
	int 0x80

exit:
	mov eax, sys_exit
	int 0x80
