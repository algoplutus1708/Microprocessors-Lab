; Write an X86/64 ALP to count number of positive and negative numbers from the array.
# 5 April 2021
# Nikhil, 3232

; A macro to print the required output 
%macro print 2				; A Macro named 'print' which takes 2 arguments
	mov rax, 1			; Assigning System Call Number to rax (1 for sys_write)
	mov rdi, 1			; Assigning File Descriptor to rdi (1 for stdout)		
	mov rsi, %1			; Assigning rsi the address of buffer to print 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall				; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here

; A macro to take input from the user
%macro enter 2				; A Macro named 'enter' which takes 2 arguments
	mov rax, 0			; Assigning System Call Number to rax (0 for sys_read)
	mov rdi, 0			; Assigning File Descriptor to rdi (0 for stdin)
	mov rsi, %1			; Assigning rsi the address of buffer to input 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall				; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here

; A macro to exit the program
%macro exit 0				; A Macro named 'exit' taking 0 arguments
	mov rax, 60			; Assigning System Call Number to rax (60 for sys_exit)
	mov rdi, 0		
	syscall				; System Call --> Generates interrupt to Kernel
%endmacro				; Macro Ends Here


; <---Data Section Starts Here--->
; All pre-initialized data is declared in this section
section .data

	; Declaring variable of Byte type named 'problem_statement'
	problem_statement db "Write an X86/64 ALP to count number of positive and negative numbers from the array."
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db "Nikhil, 3232"
	name_roll_no_len equ $-name_roll_no
	
	; Messages displayed while taking input and printing output respectively
	msg1 db "Enter number : "
	msg1_len equ $-msg1
	msg2 db 10, "Count of Positive Numbers --> "
	msg2_len equ $-msg2
	msg3 db 10, "Positive Numbers are :: ", 10
	msg3_len equ $-msg3
	msg4 db 10, "Count of Negative Numbers --> "
	msg4_len equ $-msg4
	msg5 db 10, "Negative Numbers are :: ", 10
	msg5_len equ $-msg5
	
	
	; Error Message Declared for Handling Invalid Hexadecimal Inputs
	error_msg db "Error Not a Valid 64-bit Hexadecimal Number"
	error_msg_len equ $-error_msg
	; A variable to print new line in the output(NewLine Character has ASCII value = 10)
	newline db 10
	; A variable to add horizontal tab(ASCII value = 9)
	tab db 9
	; Variables declared to keep count of the Loops in the Program
	count db 5
	count_positive db 0
	count_negative db 0
	
; <---Data Section Ends Here--->


; <---bss Section Starts Here--->
; All the uninitialized data is declared in this section
section .bss
	num resb 17			; Array of type Byte to store 17 characters(1 byte each)	
	positive resq 5			; Array of type Quad Word to store Positive Numbers
	negative resq 5			; Array of type Quad Word to store Negative Numbers
	temp resb 16			; To store the Hexadecimal Numbers converted back to ASCII
	temp_8 resb 2
	 
; <---bss Section Ends Here--->
	
	
; <---Code/Text Section Starts Here--->
section .text
	global _start			; Must be declared for linker
	_start:				; Tells linker the entry point of the program
	
		; Calling the 'print' macro for printing problem statement, name and roll no
		; Two arguments are passed to the macro i.e. buffer to print and its length
		print problem_statement, problem_len
		print newline, 1
		print name_roll_no, name_roll_no_len
		print newline, 1
		
		; Loop for taking 16 characters as input --> Calling 'ascii_hex64' procedure --> 
		; converting to hexadecimal numbers --> storing in the array positive or negative
		mov rsi, positive		; Moving array 'positive' to rsi pointer
		mov rdi, negative		; Moving array 'negative' to rsi pointer
		next_itr :			
			push rsi		; Pushing rsi to stack so its value doesn't get lost
			push rdi		; Pushing rdi to stack so its value doesn't get lost
			print tab, 1
			print msg1, msg1_len	
			enter num, 17		
			call ascii_hex64	; Calling procedure to convert ASCII value to hex
			pop rdi			; Popping rdi from stack
			pop rsi			; Popping rsi from stack
			
			bt rbx, 63		; Using bt instruction for 64th bit
			jc negative_number
			
			mov [rsi], rbx		; Assigning rbx to current index of positive array
			add rsi, 8		; Incrementing rsi by 8 (64bits = 8bytes)
			inc byte[count_positive]
			jmp next_cycle
		
		negative_number :
			mov [rdi], rbx		; Assigning rbx to current index of negative array
			add rdi, 8		; Incrementing rdi by 8 (64bits = 8bytes)
			inc byte[count_negative]
		
		next_cycle :	
			dec byte[count]		; Decrementing the count variable
		jnz next_itr			; Jump to label 'next_itr' until count becomes zero
		
		; Displaying positive numbers
		print msg2, msg2_len
		mov bl, [count_positive]
		call hex_ascii8 
		
		cmp byte[count_positive], 00H
		je neg
		
		print msg3, msg3_len
		
		; Loop for converting positive hexadecimal numbers to ASCII characters back
		mov rsi, positive		; Assigning positive array to rsi pointer for traversal
		nxt_itr :			; Label for next iteration
			mov rbx, [rsi]		; Moving value at rsi to rbx(will be used in procedure)
			push rsi		; Pushing rsi to stack
			print tab, 1
			call hex_ascii64	; Call to procedure
			pop rsi			; Popping back the rsi from stack
		
			add rsi, 8		; Adding 8 to rsi so that it points to next element
			dec byte[count_positive]
		jnz nxt_itr			; Jump to label until count2 becomes zero
	
	neg:
		; Displaying negative numbers
		print msg4, msg4_len
		mov bl, [count_negative]
		call hex_ascii8 
		
		cmp byte[count_negative], 00H
		je ext
		
		print msg5, msg5_len
		
		; Loop for converting negative hexadecimal numbers to ASCII characters back
		mov rsi, negative		; Assigning negative array to rsi pointer for traversal
		nxt_itr2 :			; Label for next iteration
			mov rbx, [rsi]		; Moving value at rsi to rbx(will be used in procedure)
			push rsi		; Pushing rsi to stack
			print tab, 1
			call hex_ascii64	; Call to procedure
			pop rsi			; Popping back the rsi from stack
		
			add rsi, 8		; Adding 8 to rsi so that it points to next element
			dec byte[count_negative]
		jnz nxt_itr2	
		print newline, 1 
		
		ext:
			exit			; Call to exit macro for exiting the program
; <---Code/Text Section Ends Here--->


; Procedures are defined below
; Procedure to Convert ASCII to 64-bit hexadecimal number and number remains in rbx register		
ascii_hex64 :
	mov rdi, num				; Moving num to rdi for traversing
	mov rax, 0				; Clearing the rax register to clear any garbage value
	mov rbx, 0				; Clearing the rbx register to clear any garbage value
	mov rcx, 16				; Setting rcx register to 16 --> loop will run 16 times
	next:					
		ROL rbx, 4			; Rotating rbx to left by 4-bits
		mov al, [rdi]			; Moving character at rdi to al register for processing
		
		; Checking for Invalid Hexadecimals
		CMP al, 29H			; Compare value in al with 29H
		jbe err				; If value <= 29H, jump to err label(error handling)
		CMP al, 40H			; Compare value in al with 40H
		je err				; If value == 40H, jump to err label(error handling)
		CMP al, 67H			; Compare value at al with 67H
		jge err				; If value >= 67H, jump to err label(error handling)
		CMP al, 47H			; Compare value at al with 47H
		jge check_further 		; If value >= 47H, jump to check further
		jmp operations			; If no error conditions are true, jump to operations
		check_further :			; check_further label to check if value between 47H-60H
			CMP al, 60H		; Compare value at al with 60H
			jbe err			; If value <= 60H, jump to err label(error handling)
		
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
			INC rdi			; Increment rdi to point to next element of num array
			DEC rcx			; Decrement the counter register
	jnz next				
ret						; Returning from the procedure

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
		INC rdi				; Incrementing rdi to point to next position
		DEC rcx				; Decrementing the counter position
	jnz lbl					; Jump to 'lbl' for next iteration
	print temp, 16				; Print temp array containing ASCII characters 
	print newline, 1
ret						; Returning from the procedure

; Procedure to convert hexadecimal number to ASCII characters for 8 bits
hex_ascii8 :
	mov rdi, temp_8				; Move temp array to rdi pointer for traversing
	mov cl, 2				; Give counter register value 2 --> Will run 2 times
	lbl8 :					
		ROL bl, 4			; Rotate bl to left by 4-bits
		mov al, bl			; bl to al(operations performed won't alter other bits)
		AND al, 0FH			; Process lower nibble only --> rest bits are made 0
		 
		CMP al, 9			; Compare value at al with 9
		jbe add30H8			; If value <= 9 (0<= value <=9) --> jump to add 30H
			
		ADD al, 7H			; Add 7H to al register
		add30H8 :
			ADD al, 30H		; Add 30H to al register
		mov [rdi], al			; Assign the value at al to rdi(pointing to temp)
		INC rdi				; Incrementing rdi to point to next position
		DEC cl				; Decrementing the counter position
	jnz lbl8				; Jump to 'lbl' for next iteration
	print temp_8, 2				; Print temp array containing ASCII characters 
	print newline, 1
ret						; Returning from the procedure
