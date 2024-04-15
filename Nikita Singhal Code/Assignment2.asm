# Write an X86/64 ALP to accept a string and to display its length
# 8th Feb 2021
# Nikhil, 3232


; A macro to print the required output 
%macro print 2				
	mov rax, 1			; Assigning System Call Number to rax (1 for sys_write)
	mov rdi, 1			; Assigning File Descriptor to rdi (1 for stdout)		
	mov rsi, %1			; Assigning rsi the address of buffer to print 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				

; A macro to take input from the user
%macro enter 2				
	mov rax, 0			; Assigning System Call Number to rax (0 for sys_read)
	mov rdi, 0			; Assigning File Descriptor to rdi (0 for stdin)
	mov rsi, %1			; Assigning rsi the address of buffer to input 
	mov rdx, %2			; Assigning length of the buffer to rdx register
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				


; All pre-initialized data is declared in Data Section
section .data

	problem_statement db "Write an X86/64 ALP to accept a string and to display its length"
	problem_len equ $-problem_statement
	name_roll_no db "Nikhil, 3232"
	name_roll_no_len equ $-name_roll_no
	
	; Declaring messages required during execution of program 
	; Finding length of messages using equ directive
	mssg_enter db "Enter the String :: "
	mssg_enter_len equ $-mssg_enter
	str_len_mssg db "The Length of the String is :: "
	mssg_len equ $-str_len_mssg
	
	newline db 10			; For new line character(ASCII value = 10)
	tab db 9			; For horizontal tab(ASCII value = 9)
	

; All the uninitialized data is declared in bss section
section .bss
	string resb 30			; String of max 30 characters to be taken as input from user
	length resb 1			; Variable to store the length of the string entered 
	temp_len resb 2		; To print the length of the string by converting to ASCII
	

; Code/Text Section starts here
section .text
	global _start			
	_start:					; Entry point of the program
		
		; Printing Problem Statements and Name, Roll No
		print newline, 1
		print problem_statement, problem_len
		print newline, 1
		print name_roll_no, name_roll_no_len
		print newline, 1
		
		print tab, 1
		print mssg_enter, mssg_enter_len	; Printing message to enter string
		enter string, 30			; Taking string as input from user
		
		; Size of the buffer(string) entered is stored in the rax register
		DEC rax				; Decrementing rax register to ignore 1 byte	
		mov [length], rax			; Assigning value of rax registeer to length
		
		print tab, 1
		print str_len_mssg, mssg_len		; Printing length message
		mov bl, [length]			; Moving length value to bl(used in Procedure)
		call convert_to_ascii			; Calling procedure to convert and print length
		
		; Generates system call for exit
		mov rax, 60	
		mov rdi, 0
		syscall

; Procedure to convert length of string to ASCII and print the converted value		
convert_to_ascii :
	mov rsi, temp_len			; Move temp_len to rsi pointer for traversing
	mov rcx, 2				; Give counter register value 2 --> Will run 2 times
	next :					
		ROL bl, 4			; Rotate bl to left by 4-bits
		mov al, bl			; bl to al(operations performed won't alter other bits)
		AND al, 0FH			; Process lower nibble only --> rest bits are made 0
		 
		CMP al, 9			; Compare value at al with 9
		jbe add30H			; If value <= 9 (0<= value <=9) --> jump to add 30H
			
		ADD al, 7H			; Add 7H to al register
		add30H :
			ADD al, 30H		; Add 30H to al register
		mov [rsi], al			; Assign the value at al to rsi(pointing to temp)
		INC rsi			; Incrementing rsi to point to next position
		DEC rcx			; Decrementing the counter register
	jnz next				
	print temp_len, 2			; Print temp_len containing ASCII characters 
	print newline, 1
ret						; Return from the Procedure
		
		 
		
		
		
		