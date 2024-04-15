; Write X86 ALP to find, a) Number of Blank spaces b) Number of lines c) Occurrence of a particular
; character. Accept the data from the text file. 

%include "macros.asm"		; Including macros.asm file which contains all macro definitions

; Declaring External and global variables
extern calculate, hex_ascii8
global count_space, count_enter, count_sp_char, buffer, sp_char, length

; <---Data Section Starts Here--->
section .data

	; Declaring variable of Byte type named 'problem_statement'
	problem_statement db "Write X86 ALP to find, a) Number of Blank spaces b) Number of lines c) Occurrence of a particular character. Accept the data from the text file.", 10
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db "Nikhil, 3232", 10 
	name_roll_no_len equ $-name_roll_no
	
	msg db 10, 9, "File Name is --> "
	msg_len equ $-msg
	msg0 db 9, 9, "----- Buffer Read from the file -----", 10
	msg0_len equ $-msg0
	msg_dash db 9, 9, "----------------------------------", 10
	msg_dash_len equ $-msg_dash
	msg1 db 9, "Enter the character to find occurence --> "
	msg1_len equ $-msg1
	msg2 db 9, "The number of spaces in the file == "
	msg2_len equ $-msg2
	msg3 db 9, "The number of new line characters in the file == "
	msg3_len equ $-msg3
	msg4 db 9, "The number of entered character in the file == "
	msg4_len equ $-msg4
	
	error_cl db " Not sufficient Command Line Arguments", 10
	error_cl_len equ $-error_cl
	err_open db " Error in opening the file!!", 10
	err_open_len equ $-err_open
	
	; Variables for counting respective character occurence
	count_space db 0
	count_enter db 0
	count_sp_char db 0
	
	newline db 10
	tab db 9

; <---bss Section Starts Here--->	
section .bss
	file_name resb 20			; To store the file name
	buffer resb 1024			; For reading the content of the file
	file_descriptor resb 8			; File descriptor for the file
	length resq 1				; For length of the buffer read
	sp_char resb 2				; For special character to be entered by user
	
; <---Code/Text Section Starts Here--->
section .text
	global _start			; Must be declared for linker
	_start:			; Tells linker the entry point of the program

		; -----------Fetching the Command-Line Arguments--------------
		mov rcx, 00H
		pop rcx		; Count of Command Line Arguments popped
		; Comparing if not 2 Arguments
		cmp rcx, 2
		jne error_cl_arguments	; Jump to print error
		
		pop rcx		; Popping Program path(not required) --> reject
		pop rcx		; Popping 1st argument address(file name)
		
		; Moving file name from command line argument in file_name variable
		mov rdx, 00H		; Clearing rdx(to be used as index)
		continue_file:
			mov al, byte[rcx + rdx]		; Moving value of that index in al
			mov byte[file_name + rdx], al		; Moving al into file_name
			cmp byte[rcx + rdx], 0			; Comparing if end of file name
			je stop	
			inc rdx
		jmp continue_file	
	stop :
		print msg, msg_len
		print file_name, 10
		print newline, 1
		
		; Opening and reading the file to read the contents
		open file_name, 00H, 0777o			; Opening for reading
		cmp rax, 00H					; If rax negative --> error
		jl error_opening				; Jump to print error
		
		mov [file_descriptor], rax			; Moving file descriptor from rax
		read [file_descriptor], buffer, 1024		; Reading into buffer
		mov [length], rax				; Calculating length of buffer
		close file_descriptor				; File closed
		
		; Taking special character from user
		print msg1, msg1_len
		enter sp_char,2
		
		; Printing the buffer read from the file
		print newline, 1
		print msg0, msg0_len
		print buffer, [length]
		print msg_dash, msg_dash_len
		
		; Calling the calculate procedure present in another program
		call calculate
		
		; Printing number of spaces
		print msg2, msg2_len
		mov bl, [count_space]
		call hex_ascii8
		
		; Printing number of newline characters
		print msg3, msg3_len
		mov bl, [count_enter]
		call hex_ascii8
		
		; Printing number of special characters
		print msg4, msg4_len
		mov bl, [count_sp_char]
		call hex_ascii8
		
		exit_loop:	
			exit				; Exit from the program
			
		; Error messages
		error_cl_arguments:
			print error_cl, error_cl_len
			jmp exit_loop
		error_opening:
			print err_open, err_open_len
			jmp exit_loop

			
		
	