; Nikhil, 3232
; A file for storing all the required macros used in other programs 

; A macro to print the required output 
%macro print 2				
	mov rax, 1			; System Call Number for sys_write
	mov rdi, 1			; File Descriptor to rdi (1 for stdout)		
	mov rsi, %1			; Address of buffer to rsi
	mov rdx, %2			; Length of the buffer to rdx 
	syscall		
%endmacro				

; A macro to take input from the user
%macro enter 2				
	mov rax, 0			; System Call Number for sys_read
	mov rdi, 0			; File Descriptor to rdi (0 for stdin)
	mov rsi, %1			; Address of buffer to rsi
	mov rdx, %2			; Length of the buffer to rdx 
	syscall		
%endmacro				

; A macro to exit the program
%macro exit 0			
	mov rax, 60			; System Call Number for sys_exit
	mov rdi, 0		
	syscall			; System Call --> Generates interrupt to Kernel
%endmacro				

; A macro to open a file
%macro open 3
	mov rax, 2			; System Call number for sys_open
	mov rdi, %1			; File name to rsi
	mov rsi, %2			; Mode of opening to rsi
	mov rdx, %3			; Permissions set to rdx
	syscall
%endmacro

; A macro to close a file
%macro close 1
	mov rax, 3			; System Call Number for sys_close
	mov rdi, %1			; File descriptor to rdi
	syscall
%endmacro

; A macro to read file contents
%macro read 3
	mov rax, 0			; System Call Number for sys_read
	mov rdi, %1			; File descriptor/pointer to rdi
	mov rsi, %2			; Buffer(to read) to rsi
	mov rdx, %3			; Length of buffer to rdx
	syscall
%endmacro

; A macro to write into a file
%macro write 3
	mov rax, 1			; System Call Number for sys_write
	mov rdi, %1			; File descriptor to rdi
	mov rsi, %2			; Buffer(to write in) to rsi
	mov rdx, %3			; Length of buffer to rdx
	syscall
%endmacro

; A macro to delete a file
%macro delete 1
	mov rax, 87			; System Call Number for delete
	mov rdi, %1			; File name to rdi
	syscall
%endmacro
