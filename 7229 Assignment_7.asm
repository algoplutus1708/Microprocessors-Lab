
;	Write X86/64 ALP to perform overlapped block transfer with string specific instructions Block containing data can be defined in the data segment.
;	Date : 26/04/2022

; Macro for write
%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

; Macro for read
%macro read 2
	mov rax, 0
	mov rdi, 0
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

section .data
	msg db "------------------MENU------------------", 10
	    db "	1. Without string instruction ", 10
	    db "	2. With string instruction ", 10
	    db "	3. Exit ", 10
	    db "Enter your choice : "
	msglen equ $-msg
	msg1 db "Number : "
	len equ $-msg1
	endl db 10
	src dq 10h, 20h, 30h, 0h, 0h, 0h   
	tab db 20h
	b db "Before : ", 10
	a db "After  : ", 10
	l equ $-a

section .bss
	temp resb 16
	choice resb 2
	
section .text
	global _start
_start :
	main_menu :
		write msg, msglen
		read choice, 2
		
		
		cmp byte[choice], "1"
		je case1
		
		cmp byte[choice], "2"
		je case2
		
		cmp byte[choice], "3"
		je case3
	
	case1 :
	; Initialize the destination with zeroes
		write b, l
		mov rcx, 3
		mov rdi, src
		add rdi, 18h
		mov rax, 0	
		init1 :
			mov [rdi], rax
			add rdi, 8
		
		loop init1
		
		call displayBlock
		write endl, 1

	; Logic for transferring the blocks
		write a, l
		mov rcx, 3
		mov rsi, src
		mov rdi, src
		add rdi, 18h
		
		next :
			mov rax, [rsi]
			mov [rdi], rax
		
			add rsi, 8
			add rdi, 8
		
		loop next
		
		call displayBlock
		write endl, 1
		
		jmp main_menu
		
	case2 :
	; Initializing the destination with zeroes
		write b, l
		mov rcx, 3
		mov rdi, src
		add rdi, 18h
		mov rax, 0	
		init2 :
			mov [rdi], rax
			add rdi, 8
		
		loop init2
		call displayBlock
		write endl, 1
	
	; Logic for transferring the blocks
		write a, l
		mov rcx, 3
		mov rsi, src
		mov rdi, src
		add rdi, 18h
		
		cld
		next2 :
			movsq
		loop next2
		
		
		call displayBlock
		write endl, 1
		
		jmp main_menu
	case3 :
		mov rax, 60
		mov rdi, 0
		syscall

displayBlock :
	mov rcx, 6
	mov rsi, src 
	
	nextD :
		push rcx
		push rsi
		
		mov rbx, [rsi]
		call display
		write tab, 1
		
		
		
		pop rbx
		push rbx
		call display
		write endl, 1
		pop rsi
		pop rcx
		
		add rsi, 8
		
		
		
		loop nextD
	write endl, 1
	
	ret
		

display :
	mov rsi, temp
	mov rcx, 16
	next1 :
		rol rbx, 4
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
			
			write temp, 16
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
