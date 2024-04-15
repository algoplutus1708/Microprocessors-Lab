; Write X86/64 ALP to perform Overlapped block transfer with & without string specific instructions.
; 17 May 2021
; Nikhil, 3232

; A macro to print the required output 
%macro print 2				; A Macro named 'print' which takes 2 arguments
	mov rax, 1			; Assigning System Call Number to rax (1 for sys_write)
	mov rdi, 1			; Assigning File Descriptor to rdi (1 for stdout)		
	mov rsi, %1			; Assigning rsi the address of buffer to print 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here

; A macro to take input from the user
%macro enter 2				; A Macro named 'enter' which takes 2 arguments
	mov rax, 0			; Assigning System Call Number to rax (0 for sys_read)
	mov rdi, 0			; Assigning File Descriptor to rdi (0 for stdin)
	mov rsi, %1			; Assigning rsi the address of buffer to input 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here

; A macro to exit the program
%macro exit 0				; A Macro named 'exit' taking 0 arguments
	mov rax, 60			; Assigning System Call Number to rax (60 for sys_exit)
	mov rdi, 0		
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here

; All pre-initialized data is declared in this section
section .data

	; Declaring variable of Byte type named 'problem_statement'
	problem_statement db 10, " Write X86/64 ALP to perform Overlapped block transfer with & without string specific instructions."
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db " Nikhil, 3232"
	name_roll_no_len equ $-name_roll_no
	
	msg_input db 10, "Enter 5 Numbers for Source Block --> ", 10
	msg_input_len equ $-msg_input
	msg1 db 10, "---------- Source Block before Transfer ----------", 10
	msg1_len equ $-msg1
	msg2 db 10, "---------- Destination Block before Transfer ----------", 10
	msg2_len equ $-msg2
	msg3 db 10, "---------- Source Block after Transfer ----------", 10
	msg3_len equ $-msg3
	msg4 db 10, "---------- Destination Block after Transfer ----------", 10
	msg4_len equ $-msg4
	
	menu db 10, " Choose from the following --> ", 10,
	     db 9, "1. Without String Specific Instruction", 10,
	     db 9, "2. With String Specific Instruction", 10,
	     db 9, "3. Exit", 10,
	     db " Your Choice :: "
	menu_len equ $-menu
	
	; Error Message Declared for Handling Invalid Hexadecimal Inputs
	error_msg db "Error Not a Valid 64-bit Hexadecimal Number"
	error_msg_len equ $-error_msg
	
	invalid db 10, 9, "Not a Valid Choice!!", 10, 9, "Enter Again!!", 10
	invalid_len equ $-invalid
	newline db 10
	tab db 9
	
	source_block times 5 dq 00H
	destination_block times 3 dq 00H
	;destination_block dq 5 dup(00H)
	
; All the uninitialized data is declared in this section
section .bss
	num resb 17				; For input of 64-bit Hex number
	choice resb 2				; For choice
	temp resb 16				; For printing in ASCII form
	count resb 5
	
; Main Program Starts Here
section .text 
	global _start			; Must be declared for linker
	_start:			; Tells linker the entry point of the program
	
		; Calling the 'print' macro for printing problem statement, name and roll no
		; Two arguments are passed to the macro i.e. buffer to print and its length
		print problem_statement, problem_len
		print newline, 1
		print name_roll_no, name_roll_no_len
		print newline, 1
		
		print msg_input, msg_input_len
		mov rsi, source_block
		mov rcx, 5
		next_it :
			push rcx
			push rsi
				enter num, 17
				mov rdi, num
				call ascii_hex64
			pop rsi
			pop rcx
			mov [rsi], rbx
			add rsi, 8
			dec rcx
		jnz next_it
		
		menu_loop:
			print menu, menu_len
			enter choice, 2
			
			case1 :
				cmp byte[choice], '1'
				jne case2
				call without_string_specific
				jmp menu_loop
			case2 :
				cmp byte[choice], '2'
				jne case3
				call with_string_specific
				jmp menu_loop
			case3 :
				cmp byte[choice], '3'
				jne rest
				jmp exit_loop
			rest :
				print invalid, invalid_len
				jmp menu_loop
			
			exit_loop :
				print newline, 1	
				exit				; Exit from the program
				
without_string_specific:
	print msg1, msg1_len
	mov rsi, source_block
	call print_block
	
	print msg2, msg2_len
	mov rsi, destination_block - 16
	call print_block
	
	; Performing Block Transfer
	mov rsi, source_block + 32
	mov rdi, destination_block + 16
	mov rcx, 5
	next_itr1 :
		mov rax, [rsi]
		mov [rdi], rax
		sub rsi, 8
		sub rdi, 8
		dec rcx
	jnz next_itr1
	
	print msg3, msg3_len
	mov rsi, source_block
	call print_block
	
	print msg4, msg4_len
	mov rsi, destination_block - 16
	call print_block
ret

with_string_specific:
	print msg1, msg1_len
	mov rsi, source_block
	call print_block
	
	print msg2, msg2_len
	mov rsi, destination_block - 16
	call print_block
	
	; Performing Block Transfer
	mov rsi, source_block + 32
	mov rdi, destination_block + 16
	std
	mov rcx, 5
	rep movsq 
	
	print msg3, msg3_len
	mov rsi, source_block
	call print_block
	
	print msg4, msg4_len
	mov rsi, destination_block - 16
	call print_block
ret

; Procedure to print the required block
print_block:
	mov rcx, 5
	next_itr :
		mov rbx, [rsi]
		push rcx
		push rsi
			call hex_ascii64
		pop rsi
		pop rcx
		add rsi, 8
		dec rcx
	jnz next_itr
ret

; Procedure to Convert ASCII to 64-bit hexadecimal number and number remains in rbx register		
ascii_hex64:
	mov rax, 0				; Clearing the rax register to clear any garbage value
	mov rbx, 0				; Clearing the rbx register to clear any garbage value
	mov rcx, 16				; Setting rcx register to 16 --> loop will run 16 times
	next :					
		ROL rbx, 4			; Rotating rbx to left by 4-bits
		mov al, [rdi]			; Moving character at rdi to al register for processing
		
		; Checking for Invalid Hexadecimals
		CMP al, 29H			; Compare value in al with 29H
		jbe err			; If value <= 29H, jump to err label(error handling)
		CMP al, 40H			; Compare value in al with 40H
		je err				; If value == 40H, jump to err label(error handling)
		CMP al, 67H			; Compare value at al with 67H
		jge err			; If value >= 67H, jump to err label(error handling)
		CMP al, 47H			; Compare value at al with 47H
		jge check_further 		; If value >= 47H, jump to check further
		jmp operations			; If no error conditions are true, jump to operations
		check_further :		; check_further label to check if value between 47H-60H
			CMP al, 60H		; Compare value at al with 60H
			jbe err		; If value <= 60H, jump to err label(error handling)
		
		; Operation on Valid Hexadecimals
		operations :
			CMP al, 39H		; Compare value at al with 39H
			jbe sub30H		; If value <= 39H(digit(0-9) entered)-->jump to sub30H 
			CMP al, 46H		; Compare value at al with 46H
			jbe sub7H		; If value <= 46H(A-F entered)-->jump to sub30H 
			SUB al, 20H		; If both conditions not true, subtract 20H from value
			sub7H :		
				SUB al, 7H	; Subtract 7H from the value at al
			sub30H :
				SUB al, 30H	; Subtract 30H from the value at al
		jmp skip			; Skip the error handling part
		
		; Error Handling part
		err :			
			print error_msg, error_msg_len	; Print the error message
			print newline, 1		
			exit				; Exit from the program
		
		; Skip part executed if no error was present
		skip :
			ADD bl, al		; Add al to bl as final hex value is stored in rbx 
			INC rdi		; Increment rdi to point to next element of num array
			DEC rcx		; Decrement the counter register
	jnz next				
ret						; Return from the procedure


; Procedure to convert hexadecimal number to ASCII characters
hex_ascii64:
	mov rdi, temp				; Move temp array to rdi pointer for traversing
	mov rcx, 16				; Give counter register value 16 --> Will run 16 times
	lbl :					
		ROL rbx, 4			; Rotate rbx to left by 4-bits
		mov al, bl			; bl to al(operations performed won't alter other bits)
		AND al, 0FH			; Process lower nibble only --> rest bits are made 0
		 
		CMP al, 9			; Compare value at al with 9
		jbe add30H			; If value <= 9 (0<= value <=9) --> jump to add 30H
			
		ADD al, 7H			; Add 7H to al register
		add30H :
			ADD al, 30H		; Add 30H to al register
		
		mov [rdi], al			; Assign the value at al to rdi(pointing to temp)
		INC rdi			; Incrementing rdi to point to next position
		DEC rcx			; Decrementing the counter position
	jnz lbl				; Jump to 'lbl' for next iteration
	print tab, 1
	print temp, 16				; Print temp array containing ASCII characters 
	print newline, 1
ret						; Returning from the procedure
