; Write X86 menu driven Assembly Language Program (ALP) to implement OS (DOS) commands TYPE, COPY and
; DELETE using file operations. User is supposed to provide command line arguments in all cases.
; Nikhil, 3232

%include "macros.asm"		; Including macros.asm file which contains all macro definitions

; <---Data Section Starts Here--->
section .data

	; Declaring variable of Byte type named 'problem_statement'
	problem_statement db "Write X86 menu driven Assembly Language Program (ALP) to implement OS (DOS) commands TYPE, COPY and DELETE using file operations. User is supposed to provide command line arguments in all cases.", 10
	; Calculating the length of the variable by using equ directive
	problem_len equ $-problem_statement
	name_roll_no db "Nikhil, 3232", 10 
	name_roll_no_len equ $-name_roll_no
	
	menu db 10, " Choose from the following --> ", 10,
	     db 9, "1. TYPE into the file", 10,
	     db 9, "2. COPY the file contents", 10,
	     db 9, "3. DELETE the file", 10,
	     db 9, "4. EXIT", 10,
	     db " Your Choice :: "
	menu_len equ $-menu
	
	msg1 db 10, " Type the buffer to Append to file1 --> ", 10, 9
	msg1_len equ $-msg1
	msg2 db 10, " ----------- Content Appended to file1 ----------- ", 10
	msg2_len equ $-msg2
	msg3 db 10, " ---- Copying contents of file1 to file2 ---- "
	msg3_len equ $-msg3
	msg4 db 10, "--------- Contents Copied to file2 --------- "
	msg4_len equ $-msg4
	msg5 db 10, " ---------- Deleting File2 ----- "
	msg5_len equ $-msg5
	msg6 db 10, " ---------- File2 Deleted --------- "
	msg6_len equ $-msg6
	
	invalid db "Not a Valid Choice! Enter Again!!"
	invalid_len equ $-invalid
	
	error_cl db 10, " Not valid quantity Command Line Arguments", 10
	error_cl_len equ $-error_cl
	err_open db " Error in opening the file!!", 10
	err_open_len equ $-err_open
	
	newline db 10
	tab db 9
; <---Data Section Ends Here--->


; <---bss Section Starts Here--->
section .bss
	choice resb 2
	file1 resb 20
	file2 resb 20
	buffer resb 60
	length resq 1
	file_descriptor resb 8
	
; <---Data Section Ends Here--->

; <---Code/Text Section Starts Here--->
section .text
	global _start			; Must be declared for linker
	_start:			; Tells linker the entry point of the program
		
		; -----------------Fetching the Command-Line Arguments-----------------
		mov rcx, 00H
		pop rcx		; Count of Command Line Arguments popped
		; Comparing if only 1 Argument (Program Path)
		cmp rcx, 1
		je insufficient_cl	; Jump to print error
		cmp rcx, 3
		jg insufficient_cl	; Jump to print error
		
		pop rcx		; Popping Program path(not required)
		pop rcx
		
		mov rdx, 00H		; Clearing rdx(to be used as index)
		continue_file1:
			mov al, byte[rcx + rdx]
			mov byte[file1 + rdx], al
			cmp byte[rcx + rdx], 0
			je stop
			inc rdx
		jmp continue_file1
		; ------------ Fetching of 1st File name Finished -----------
		stop:
			pop rcx
			mov rdx, 00H		; Clearing rdx(to be used as index)
		continue_file2:
			mov al, byte[rcx + rdx]
			mov byte[file2 + rdx], al
			cmp byte[rcx + rdx], 0
			je stop_cl_reading
			inc rdx
		jmp continue_file2
		
		; ------------ Fetching of 2nd File name Finished -----------
		stop_cl_reading:
			print problem_statement, problem_len
			print name_roll_no, name_roll_no_len
			
			; Menu to choose from
			menu_loop:
				print menu, menu_len
				enter choice, 2
				case1 :
					cmp byte[choice], '1'
					jne case2
					call type_command
					jmp menu_loop
				case2 :
					cmp byte[choice], '2'
					jne case3
					call copy_command
					jmp menu_loop
				case3 :
					cmp byte[choice], '3'
					jne case4
					call delete_command
					jmp menu_loop
				case4 :
					cmp byte[choice], '4'
					jne rest
					jmp exit_loop
				rest :
					print invalid, invalid_len
					jmp menu_loop
			exit_loop:
				exit				; Exit from the program
			
		; Error messages displayed as and when required
		insufficient_cl:
			print error_cl, error_cl_len
			jmp exit_loop
		error_opening:
			print err_open, err_open_len
			jmp exit_loop

; Procedure to append the content typed by user into file1		
type_command:
	print msg1, msg1_len
	enter buffer, 60
	dec rax					; Taking the buffer input
	mov [length], rax				; Length of the buffer in rax
	mov byte[buffer + rax], 0				; Marking end of file
	
	open file1, 441H, 0777H			; Opening the file(write, create, append)
	cmp rax, 00H
	jl error_opening
	mov [file_descriptor], rax			; File descriptor in rax
	
	write [file_descriptor], buffer, [length]	; Writing the buffer in the file
	close [file_descriptor]			; Closing the file
	
	print msg2, msg2_len
ret

; Procedure to read from file1 and copy into file2
copy_command:
	print msg3, msg3_len
	print newline, 1
	
	; Extracting content from file1
	open file1, 00H, 0777H				; Opening for reading
	mov [file_descriptor], rax			; File descriptor in rax
	read [file_descriptor], buffer, 1024		; Reading contents of file
	mov [length], rax				; Length of the content read in rax
	close [file_descriptor]			; Close file
	
	print buffer, [length]				; Printing file content
	
	; Copying into file2
	open file2, 41H, 0777H				; Opening in write & create mode
	mov [file_descriptor], rax			
	write [file_descriptor], buffer, [length]	; Writing into file
	close [file_descriptor]			; Close the file
	
	print msg4, msg4_len
ret

; Procedure to delete file2
delete_command:
	print msg5, msg5_len					
	; Calling macro to delete file2
	delete file2
	print msg6, msg6_len
ret

