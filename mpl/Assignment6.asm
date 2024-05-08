; Write X86/64 ALP to convert 
; a) 4-digit Hex number into its equivalent BCD number and 
; b) 5-digit BCD number into its equivalent HEX number.

; 12th March 2021
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
	problem_statement db " Write X86/64 ALP to convert", 10, 9," a) 4-digit Hex number into its equivalent BCD number and", 10, 9, " b) 5-digit BCD number into its equivalent HEX number."
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db " Nikhil, 3232"
	name_roll_no_len equ $-name_roll_no
	
	msg1 db 10, " Enter Hexadecimal Number --> "
	msg1_len equ $-msg1
	msg2 db " Equivalent BCD number is --> "
	msg2_len equ $-msg2
	msg3 db 10, " Enter BCD number for conversion  --> "
	msg3_len equ $-msg3
	msg4 db  " Equivalent Hexadecimal number is --> "
	msg4_len equ $-msg4
	
	; Error Message Declared for Handling Invalid Hexadecimal Inputs
	error_msg db "Error Not a Valid 64-bit Hexadecimal Number"
	error_msg_len equ $-error_msg
	
	menu db 10, " Choose from the following --> ", 10,
	     db 9, "1. Hexadecimal to BCD", 10,
	     db 9, "2. BCD to Hexadecimal", 10,
	     db 9, "3. Exit", 10,
	     db " Your Choice :: "
	menu_len equ $-menu
	
	invalid db 10, 9, "Not a Valid Choice!!", 10, 9, "Enter Again!!", 10
	invalid_len equ $-invalid
	newline db 10
	tab db 9
	
; All the uninitialized data is declared in this section
section .bss
	num1 resb 6				; For input of 4-digit Hex number or 5-digit BCD number
	hex resw 1				; For converted 16-bit hexadecimal number
	choice resb 2				; For choice
	temp resb 4				; For printing in ASCII form
	digit resb 1
	
section .text 
	global _start			; Must be declared for linker
	_start:			; Tells linker the entry point of the program
	
		; Calling the 'print' macro for printing problem statement, name and roll no
		; Two arguments are passed to the macro i.e. buffer to print and its length
		print problem_statement, problem_len
		print newline, 1
		print name_roll_no, name_roll_no_len
		print newline, 1
		
		menu_loop:
			print menu, menu_len
			enter choice, 2

			case1 :
				cmp byte[choice], '1'
				jne case2
				call hex_to_bcd
				jmp menu_loop
			case2 :
				cmp byte[choice], '2'
				jne case3
				call bcd_to_hex
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
				
; Procedure to Convert Hexadecimal number into equivalent BCD number				
hex_to_bcd:
	print msg1, msg1_len
	enter num1, 5				; Entering 4 digit hexadecimal number
	
	mov rdi, num1
	call ascii_hex16			; For converting input number to hexadecimal form
	mov [hex], bx				; Transferring converted value to hex variable
	
	mov bx, 0AH				; divisor = 10(0AH)
	mov ax, [hex]				; Moving hex number to ax register for divison
	mov rcx, 5				; Loop will run for 5 times --> 5 digit BCD number
	next_itr :
		mov rdx, 00H			; Clearing rdx register for any other value

		; For division instruction (divisor is 16-bits)	
			; Dividend --> dx:ax 
			; Divisor --> 16 bits (in bx for this program)
		div bx				
			; Quotient in ax register
			; Remainder in dx register
		
		add dx, 30H			; Adding 30H to remainder to convert into ASCII
		push rdx			; Pushing rdx register onto stack
		dec rcx	
	jnz next_itr
	
	print msg2, msg2_len
	mov rcx, 5	
	next_itr1 :
		pop rdx			; Pop rdx register to print remainder
		mov [digit], dx		; Moving dx to variable digit
		push rcx
		print digit, 1			; Printing the popped digit 
		pop rcx
		dec rcx
	jnz next_itr1
	
	print newline, 1	
ret

; Procedure to Convert BCD number to Hexadecimal number
bcd_to_hex:
	print msg3, msg3_len
	enter num1, 6				; Entering 5-digit BCD number
	
	mov rdi, num1				; rdi pointing to num1(BCD number) entered
	mov bx, 0AH				; Multiplicand is 0AH
	mov ax, 00H				; Initially the source is 00H i.e. ax = 00H
	
	mov rcx, 5				; Loop will run for 5 times
	next_itr2 :
		mul bx				; Multiplication instruction to multiply ax with bx
		; Product is stored in dx:ax but we only need the lower part i.e. value in ax
		mov dx, 00H			; Clearing dx register
		mov dl, [rdi]			; dl equals to the current element pointed by rdi
		sub dl, 30H			; Subtracting 30H from dl to convert into hexadecimal
		add ax, dx			; Adding dx to ax --> source for next multiplication
		inc rdi			; Incrementing rdi to point to next element
		
		dec rcx		
	jnz next_itr2
	
	push rax			; Converted hexadecimal is stored in ax so important to push
	print msg4, msg4_len
	pop rax
	
	mov bx, ax			; Moving ax to bx register --> will be used in procedure ahead
	call hex_ascii16		; To convert hexadecimal number to ASCII to print
ret


; Procedure to convert 16-bit ASCII into hexadecimal number (Final result is stored in bx register)
ascii_hex16 :
	mov ax, 0				; Clearing the ax register to clear any garbage value
	mov bx, 0				; Clearing the bx register to clear any garbage value
	mov cx, 4				; Setting cx register to 4 --> loop will run 4 times
	next:					
		ROL bx, 4			; Rotating bx to left by 4-bits
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
			ADD bl, al		; Add al to bl as final hex value is stored in bx 
			INC rdi		; Increment rdi to point to next element of num array
			DEC cx			; Decrement the counter register
	jnz next				
ret

; Procedure to convert hexadecimal number to ASCII characters
hex_ascii16 :
	mov rdi, temp				; Move temp array to rdi pointer for traversing
	mov cx, 4				; Give counter register value 4 --> Will run 4 times
	lbl :					
		ROL bx, 4			; Rotate bx to left by 4-bits
		mov al, bl			; bl to al(operations performed won't alter other bits)
		AND al, 0FH			; Process lower nibble only --> rest bits are made 0
		 
		CMP al, 9			; Compare value at al with 9
		jbe add30H			; If value <= 9 (0<= value <=9) --> jump to add 30H
			
		ADD al, 7H			; Add 7H to al register
		add30H :
			ADD al, 30H		; Add 30H to al register
		mov [rdi], al			; Assign the value at al to rdi(pointing to temp)
		INC rdi			; Incrementing rdi to point to next position
		DEC cx				; Decrementing the counter position
	jnz lbl				; Jump to 'lbl' for next iteration
	print temp, 4				; Print temp array containing ASCII characters 
	print newline, 1
ret						; Returning from the procedure
