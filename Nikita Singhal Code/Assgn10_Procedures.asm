; Program to contain all the utility procedures required in other program
%include "macros.asm"

; Defining global data and external data
global calculate, hex_ascii8
extern count_space, count_enter, count_sp_char, buffer, sp_char, length

section .data
	newline db 10
	;------------------
section .bss
	temp resb 2
	;------------------
section .text
	global xyz
	xyz:
		; Procedure to calculate Number of spaces, newlines, special character
		calculate:
			mov rsi, buffer			; Buffer into rsi to traverse
			mov rcx, [length]			; Loop will run for length no of times
			continue :
				push rcx
				mov al, [rsi]			; Current element into al
				cmp al, 20H			; Comparing if space
				jne down1
				inc byte[count_space]		; Incrementing counter
				jmp down3
			down1 :
				cmp al, 0AH			; Comparing for newline
				jne down2
				inc byte[count_enter]		; Incrementing counter
				jmp down3
			down2 :
				cmp al, byte[sp_char]		; Comparing if special character
				jne down3
				inc byte[count_sp_char]	; Incrementing counter
			down3 :
				inc rsi			; Next element
				pop rcx
				dec rcx
			jnz continue
		ret

; Procedure to convert hexadecimal number to ASCII characters
hex_ascii8 :
	mov rdi, temp				; Move temp array to rdi pointer for traversing
	mov cl, 2				; Give counter register value 2 --> Will run 2 times
	lbl :					
		ROL bl, 4			; Rotate bl to left by 4-bits
		mov al, bl			; bl to al(operations performed won't alter other bits)
		AND al, 0FH			; Process lower nibble only --> rest bits are made 0
		 
		CMP al, 9			; Compare value at al with 9
		jbe add30H			; If value <= 9 (0<= value <=9) --> jump to add 30H
			
		ADD al, 7H			; Add 7H to al register
		add30H :
			ADD al, 30H		; Add 30H to al register
		mov [rdi], al			; Assign the value at al to rdi(pointing to temp)
		INC rdi			; Incrementing rdi to point to next position
		DEC cl				; Decrementing the counter position
	jnz lbl				; Jump to 'lbl' for next iteration
	print temp, 2
	print newline, 1		
ret						; Returning from the procedure
