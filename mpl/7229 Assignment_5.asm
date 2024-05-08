
;	Write X86/64 ALP to convert 4-digit Hex number into its equivalent BCD number and 5- digit BCD number into its equivalent HEX number. Make your program user friendly to accept the choice from user for: (a) HEX to BCD b) BCD to HEX (c) EXIT.
;	Display proper strings to prompt the user while accepting the input and displaying the result. (Wherever necessary, use 64-bit registers).

; Macro for write to stdout
%macro write 2
	mov rax, 1        ; System call number for write
	mov rdi, 1        ; File descriptor for stdout
	mov rsi, %1       ; Address of the string to print
	mov rdx, %2       ; Length of the string
	syscall           ; Invoke syscall to print
%endmacro

; Macro for read from stdin
%macro read 2
	mov rax, 0        ; System call number for read
	mov rdi, 0        ; File descriptor for stdin
	mov rsi, %1       ; Address where input will be stored
	mov rdx, %2       ; Maximum number of bytes to read
	syscall           ; Invoke syscall to read
%endmacro

section .data
	msg db "------------------MENU------------------", 10
	    db "    1. Hex to BCD ", 10
	    db "    2. BCD to Hex ", 10
	    db "    3. Exit ", 10
	    db "Enter your choice : "
	msglen equ $-msg      ; Calculate the length of the menu string
	msg1 db "Number : "   ; Prompt for number input
	len equ $-msg1        ; Calculate the length of the prompt
	endl db 10            ; Newline character
	
section .bss
	num resd 1            ; Reserve space for a single dword (4 bytes)
	choice resb 2         ; Reserve space for choice input
	
	a_hex resb 5          ; Reserve space for a 4-digit hexadecimal number
	a_bcd resb 6          ; Reserve space for a 5-digit BCD number
	buffer resb 5         ; Reserve space for temporary buffer
	temp resb 4           ; Reserve space for temporary conversion storage
	
section .text
	global _start
_start :
	main_menu :
		write msg, msglen  ; Display the menu
		read choice, 2     ; Read the user's choice
		
		; Compare the choice and jump to appropriate case
		cmp byte[choice], "1"
		je case1
		
		cmp byte[choice], "2"
		je case2
		
		cmp byte[choice], "3"
		je case3
		
		; If choice is invalid, go back to main menu
		jmp main_menu
	
	; Case for converting Hexadecimal to BCD
	case1 :
		write msg1, len    ; Prompt for input
		read a_hex, 5      ; Read the 4-digit hexadecimal number
		call hex_bcd       ; Convert Hexadecimal to BCD
		jmp main_menu      ; Go back to main menu
		
	; Case for converting BCD to Hexadecimal
	case2 :
		write msg1, len    ; Prompt for input
		read a_bcd, 6      ; Read the 5-digit BCD number
		call bcd_hex       ; Convert BCD to Hexadecimal
		jmp main_menu      ; Go back to main menu
		
	; Case for Exit
	case3 :
		mov rax, 60        ; Exit syscall number
		mov rdi, 0         ; Exit code 0
		syscall            ; Invoke syscall to exit

; Procedure to convert a hexadecimal number to BCD
hex_bcd:
	call ascii_hex       ; Convert the number to hexadecimal
	mov ax, bx           ; Move the hexadecimal number to ax
	mov bx, 0AH          ; Set bx to 10
	
	mov rcx, 5           ; Loop for 5 digits
	convert:
		mov rdx, 0       ; Clear rdx
		div bx           ; Divide ax by 10
		push dx          ; Store remainder (BCD digit) in stack
		
		loop convert     ; Repeat for each digit
	
	mov rcx, 5           ; Loop for 5 digits
	mov rsi, buffer     ; Point to buffer
	print_bcd:
		pop ax           ; Pop BCD digit from stack (in reverse order)
		add ax, 30h      ; Convert to ASCII
		mov [rsi], ax    ; Store in buffer
		inc rsi          ; Move to next position in buffer
		
		loop print_bcd   ; Repeat for each digit
	
	write buffer, 5      ; Display the BCD number
	write endl, 1       ; Newline
	ret                  ; Return

; Procedure to convert a BCD number to hexadecimal
bcd_hex:
	mov rsi, a_bcd       ; Point to BCD number
	mov rcx, 5           ; Loop for 5 digits
	mov bx, 0AH          ; Set bx to 10
	mov rax, 0           ; Initialize rax to 0
	
	b_convert:
		mul bx           ; Multiply rax by 10
		mov dl, [rsi]    ; Load BCD digit from memory
		sub dl, 30h      ; Convert ASCII to digit
		add al, dl       ; Add digit to rax
		
		inc rsi          ; Move to next digit
		loop b_convert   ; Repeat for each digit
	
	mov bx, ax           ; Move result to bx for display
	call display         ; Display the result
	ret                  ; Return

; Procedure to convert ASCII to hexadecimal
ascii_hex:
	mov rbx, 0           ; Clear rbx
	mov rsi, a_hex       ; Point to input string
	mov rcx, 4           ; Loop for 4 digits
	
	next:
		rol bx, 4        ; Rotate rbx left by 4 bits
		mov al, [rsi]    ; Load ASCII character
		cmp al, '9'      ; Check if character is less than or equal to '9'
		jbe sub30h       ; If so, jump to subtraction
		sub al, 7h       ; Otherwise, subtract 7 to convert from 'A' to 'F'
		
	sub30h:               ; Subtract '0'
		sub al, 30h      ; Subtract '0' to convert ASCII to digit
		add bl, al       ; Add to rbx
		inc rsi          ; Move to next character
		loop next        ; Repeat for each digit
		
	ret                  ; Return

; Procedure to convert hexadecimal to ASCII
display:
	mov rsi, temp        ; Point to temporary buffer
	mov rcx, 4           ; Loop for 4 digits
	
	next1:
		rol bx, 4        ; Rotate bx left by 4 bits
		mov al, bl       ; Load lower 8 bits of bx into al
		and al, 0Fh      ; Mask upper 4 bits to get lower 4 bits
		cmp al, 9        ; Check if digit is greater than 9
		jbe add30h       ; If not, jump to addition
		
		add al, 7h       ; Convert digit to ASCII ('A' to 'F')
		add30h:          ; Addition for '0'
			add al, 30h  ; Add '0' to convert digit to ASCII
		
		mov [rsi], al    ; Store ASCII digit in buffer
		inc rsi          ; Move to next position in buffer
		loop next1       ; Repeat for each digit
	
	write temp, 4        ; Display the result
	write endl, 1        ; Newline
	ret                  ; Return
