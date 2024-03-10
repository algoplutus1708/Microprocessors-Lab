;	Name : Khushi
; Display length of a string

%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro read 2
	mov rax, 0
	mov rdi, 0
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

section .data
	msg1 db "Enter a String : "
	msg1len equ $-msg1
	endl db 10

section .bss
	string resb 30
	temp resb 2

	
section .text
	global _start
_start :

	write msg1, msg1len
	write endl, 1
	
	read string, 30
	
	dec rax
	mov rbx, rax
	
	call display
	
	;write endl, 1
	
	
	mov rax, 60
	mov rsi, 0
	syscall 
	
	
display :
	mov rsi, temp
	mov rcx, 2
	next1 :
		rol bl, 4
		mov al, bl
		and al, 0Fh
		cmp al, 9
		jbe add30h
		
		add al, 7h
		
		add30h :
			add al, 30h
			mov [rsi], al
			inc rsi
			loop next1
			
		write temp, 2
		write endl, 1
		ret
	
	
