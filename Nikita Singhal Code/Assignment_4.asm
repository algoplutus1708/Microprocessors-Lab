; Write a switch case driven X86/64 ALP to perform 64-bit hexadecimal arithmetic operations

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
	problem_statement db "Write a switch case driven X86/64 ALP to perform 64-bit hexadecimal arithmetic operations"
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db "Nikhil, 3232"
	name_roll_no_len equ $-name_roll_no
	
	; Messages displayed while taking input and printing output respectively
	msg1 db 9, "Enter 1st number : "
	msg1_len equ $-msg1
	msg2 db 9, "Enter 2nd number : "
	msg2_len equ $-msg2
	msg3 db 9, "Enter the divisor  : "
	msg3_len equ $-msg3
	msg4 db 9, "Enter the dividend : "
	msg4_len equ $-msg4
	
	; Error Message Declared for Handling Invalid Hexadecimal Inputs
	error_msg db "Error Not a Valid 64-bit Hexadecimal Number"
	error_msg_len equ $-error_msg
	
	; Messages to be displayed after performing the respective operations
	sum_msg db 9, "  Sum is : "
	sum_msg_len equ $-sum_msg
	diff_msg db 9, "   Difference is : "
	diff_msg_len equ $-diff_msg
	prod_msg db 9, 9, " Product : "
	prod_msg_len equ $-prod_msg
	quot_msg db 9, "      Quotient is  : "
	quot_msg_len equ $-quot_msg
	rem_msg db 9, "     Remainder is  : "
	rem_msg_len equ $-rem_msg
	
	; Defining menu
	menu db 10, "Choose from the following --> ", 10,
	     db 9, "1. Addition", 10,
	     db 9, "2. Subtraction", 10,
	     db 9, "3. Multiplication", 10,
	     db 9, "4. Division", 10,
	     db 9, "5. Exit", 10,
	     db "Your Choice :: "
	menu_len equ $-menu
	
	invalid db 10, 9, "Not a Valid Choice!!", 10, 9, "Enter Again!!", 10
	invalid_len equ $-invalid
	newline db 10
	tab db 9
	space db 20
	backspace db 8


; All the uninitialized data is declared in this section
section .bss
	num1 resb 17			; For inserting first operand for Addition, Subtraction
	num2 resb 17			; For inserting second operand for Addition, Subtraction
	num3 resb 9			; For divisor for division operation
	hex1 resq 1			; First hexadecmial operand
	hex2 resq 1			; Second hexadecimal operand
	divisor resd 1			; To store divisor of size 32-bit(double word)
	choice resb 2			; For entering user's choice
	temp resb 16			; For printing the results of various operations
	
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
				print newline, 1
				call addition
				jmp menu_loop
			case2 :
				cmp byte[choice], '2'
				jne case3
				print newline, 1
				call subtraction 
				jmp menu_loop
			case3 :
				cmp byte[choice], '3'
				jne case4
				print newline, 1
				call multiplication
				jmp menu_loop 
			case4 :
				cmp byte[choice], '4'
				jne case5
				print newline, 1
				call division 
				jmp menu_loop
			case5 :
				cmp byte[choice], '5'
				jne case6
				jmp exit_loop
			case6 :
				print invalid, invalid_len
				jmp menu_loop
			
			exit_loop :
				print newline, 1	
				exit
	
	
; Procedure to perform addition of two operands
addition:
	print msg1, msg1_len
	enter num1, 17			; Taking first operand from user		
	print msg2, msg2_len
	enter num2, 17			; Taking second operand from user
	
	mov rdi, num1			; Moving first operand in rdi (for procedure ahead)
	call ascii_hex64		; After procedure, converted value is in rbx register
	mov [hex1], rbx		; Moving the value of rbx in hex1 variable
	
	mov rdi, num2			; Moving second operand in rdi (for procedure ahead)
	call ascii_hex64		; After procedure, converted value is in rbx register
	mov [hex2], rbx		; Moving the value of rbx in hex2 variable
	
	mov rax, [hex1]		; Moving value of first operand into rax register
	add rax, [hex2]		; ADD instruction to add the operands
	; Result of the addition operation came into rax register
	mov rbx, rax			; Assigning the result to rbx register to print it
	
	print tab, 1
	print sum_msg, sum_msg_len
	call hex_ascii64		; Printing the result of addition using procedure
	print newline, 1
ret


; Procedure to perform subtraction of two operands
subtraction:
	print msg1, msg1_len
	enter num1, 17			; Taking first operand from user	
	print msg2, msg2_len
	enter num2, 17			; Taking second operand from user
	
	mov rdi, num1			; Moving first operand in rdi (for procedure ahead)
	call ascii_hex64		; After procedure, converted value is in rbx register
	mov [hex1], rbx		; Moving the value of rbx in hex1 variable
	
	mov rdi, num2
	call ascii_hex64
	mov [hex2], rbx
	
	mov rax, [hex1]		; Moving value of first operand into rax register
	sub rax, [hex2]		; SUB instruction to subtract two operands
	; Result of the subtraction operation came into rax register
	mov rbx, rax			; Assigning the result to rbx register to print it
	
	print diff_msg, diff_msg_len
	call hex_ascii64		; Printing the result of addition using procedure
	print newline, 1
ret


; Procedure to perform multiplication of two operands
multiplication:
	print msg1, msg1_len
	enter num1, 17			; Taking first operand as input		
	print msg2, msg2_len
	enter num2, 17			; Taking second input as input
	
	mov rdi, num1			; Moving num1 in rdi
	call ascii_hex64		; Caliing procedure to convert to ASCII
	mov [hex1], rbx		; Moving the rbx register into the operand
	
	mov rdi, num2
	call ascii_hex64
	mov [hex2], rbx
	
	mov rax, [hex1]		; Moving first operand in rax register
	mov rbx, [hex2]		; Moving second operand in rbx register
	
	mul rbx			; Result of multiplication stored in RDX:RAX registers
	
	push rax
	push rdx
	
	print prod_msg, prod_msg_len	; Printing the multiplication message
	;pop rax
	pop rdx
	
	mov rbx, rdx			; Moving the value of rdx in rbx register to print it
	;push rax			; Pushing rax register to stack 
	call hex_ascii64		; To display value of rdx register
	print space, 1
	pop rax
		
	mov rbx, rax			; Moving the value of rax in rbx register to print it
	call hex_ascii64		; To display value of rax register
	print newline, 1
ret


; Procedure to perform division of dividend by divisor
division:
	print msg3, msg3_len
	enter num3, 9
	print msg4, msg4_len
	enter num1, 17
	
	; dividend --> EDX:EAX
	mov rdi, num3
	call ascii_hex32		; Calling procedure to convert divisor to hexadecimal
	mov [divisor], rbx		; Storing rbx register in divisor variable
	
	mov rdi, num3			; Destination is num3
	mov rsi, num1			; Source is num1
	cld				; Clearing direction flag --> rsi and rdi will increment
	mov cx, 8			; First 8 characters 
	rep movsb			; mov bytes from source to destination until cx != 0
	
	mov rdi, num3			; Moving num3 to rdi for procedure ahead
	call ascii_hex32		; Call to procedure to convert to hexadecimal
	mov edx, ebx			; Mov ebx register to edx
		
	mov rdi, num3			; Destination is num3
	mov rsi, num1+8		; Source is num1
	cld				; Setting direction flag --> rsi and rdi will decrement
	mov cx, 8			; Last 8 bytes
	rep movsb			; Move bytes from source to destination until cx != 0
	
	mov rdi, num3			; Moving num3 to rdi for procedure ahead
	push rdx			; push rdx onto stack
	call ascii_hex32		; Call to procedure for converting to hexadecimal
	pop rdx
	mov eax, ebx			; Move ebx to eax
		
	mov ebx, [divisor]		; Move divisor tp ebx
	div ebx			; DIV instruction to divide dividend(edx eax) by divisor
	; Quotient is stored in EAX and remainder is stored in EDX
	
	push rax
	push rdx
	print quot_msg, quot_msg_len	; Printing Quotient message
	pop rdx
	pop rax
	
	mov ebx, eax			; Moving eax to ebx for procedure
	push rdx
	call hex_ascii64		; Call to procedure to print Quotient
	pop rdx
	
	push rdx
	print newline, 1
	print rem_msg, rem_msg_len	; Printing remainder message
	pop rdx
	
	mov ebx, edx			; Moving edx register to ebx
	call hex_ascii64		; Call procedure to print remainder
	print newline, 1
ret
; Procedure to Convert ASCII to 64-bit hexadecimal number and number remains in rbx register		
ascii_hex64 :
	; mov rdi, num				; Moving num to rdi for traversing
	mov rax, 0				; Clearing the rax register to clear any garbage value
	mov rbx, 0				; Clearing the rbx register to clear any garbage value
	mov rcx, 16				; Setting rcx register to 16 --> loop will run 16 times
	next:					
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
ret	

; Procedure to convert hexadecimal number to ASCII characters
hex_ascii64 :
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
	print temp, 16				; Print temp array containing ASCII characters 
ret						; Returning from the procedure


; Procedure to Convert ASCII to 32-bit hexadecimal number and number remains in ebx register		
ascii_hex32 :
	; mov rdi, num				; Moving num to rdi for traversing
	mov eax, 0				; Clearing the eax register to clear any garbage value
	mov ebx, 0				; Clearing the ebx register to clear any garbage value
	mov ecx, 8				; Setting ecx register to 8 --> loop will run 8 times
	next1:					
		ROL ebx, 4			; Rotating ebx to left by 4-bits
		mov al, [rdi]			; Moving character at rdi to al register for processing
		
		; Checking for Invalid Hexadecimals
		CMP al, 29H			; Compare value in al with 29H
		jbe err1			; If value <= 29H, jump to err label(error handling)
		CMP al, 40H			; Compare value in al with 40H
		je err1			; If value == 40H, jump to err label(error handling)
		CMP al, 67H			; Compare value at al with 67H
		jge err1			; If value >= 67H, jump to err label(error handling)
		CMP al, 47H			; Compare value at al with 47H
		jge check_further1 		; If value >= 47H, jump to check further
		jmp operations1		; If no error conditions are true, jump to operations
		check_further1 :		; check_further label to check if value between 47H-60H
			CMP al, 60H		; Compare value at al with 60H
			jbe err1		; If value <= 60H, jump to err label(error handling)
		
		; Operation on Valid Hexadecimals
		operations1 :
			CMP al, 39H		; Compare value at al with 39H
			jbe sub30H_		; If value <= 39H(digit(0-9) entered)-->jump to sub30H 
			CMP al, 46H		; Compare value at al with 46H
			jbe sub7H_		; If value <= 46H(A-F entered)-->jump to sub30H 
			SUB al, 20H		; If both conditions not true, subtract 20H from value
			sub7H_ :		
				SUB al, 7H	; Subtract 7H from the value at al
			sub30H_ :
				SUB al, 30H	; Subtract 30H from the value at al
		jmp skip1			; Skip the error handling part
		
		; Error Handling part
		err1 :			
			print error_msg, error_msg_len	; Print the error message
			print newline, 1		
			exit				; Exit from the program
		
		; Skip part executed if no error was present
		skip1 :
			ADD bl, al		; Add al to bl as final hex value is stored in ebx 
			INC rdi		; Increment rdi to point to next element of num array
			DEC ecx		; Decrement the counter register
	jnz next1				
ret