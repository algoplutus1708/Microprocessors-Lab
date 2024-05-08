; Define a macro to write to stdout
%macro write 2
	mov rax, 1        ; System call number for write
	mov rdi, 1        ; File descriptor for stdout
	mov rsi, %1       ; Address of the string to print
	mov rdx, %2       ; Length of the string
	syscall           ; Invoke syscall to print
%endmacro

; Define a macro to read from stdin
%macro read 2
	mov rax, 0        ; System call number for read
	mov rdi, 0        ; File descriptor for stdin
	mov rsi, %1       ; Address where input will be stored
	mov rdx, %2       ; Maximum number of bytes to read
	syscall           ; Invoke syscall to read
%endmacro

section .data
	msg1 db "Number : "    ; Prompt for number input
	msg1len equ $-msg1     ; Length of the prompt
	endl db 10             ; Newline character
	pcount db 0            ; Counter for positive numbers
	ncount db 0            ; Counter for negative numbers
	
section .bss
	hexnum resq 5          ; Array to store hexadecimal numbers
	num1 resb 17           ; Temporary storage for input number
	temp resb 16           ; Temporary storage for ASCII conversion
	
section .text
	global _start
_start:
	mov rcx, 5              ; Loop counter for 5 numbers
	mov rsi, hexnum         ; Pointer to hexnum array
nextnum:
	push rcx                ; Save loop counter
	push rsi                ; Save array pointer
	
	read num1, 17           ; Read input number
	
	call ascii_hex          ; Convert ASCII input to hexadecimal
	
	pop rsi                 ; Restore array pointer
	pop rcx                 ; Restore loop counter
	
	mov [rsi], rbx          ; Store hexadecimal number in array
	add rsi, 8              ; Move to next element in array
	
	bt rbx, 63              ; Check the msb (if the number is negative)
	jnc pcnt                ; If not negative, increment positive count
	
	inc byte[ncount]        ; Increment negative count
	jmp cont                ; Continue to next number
	
pcnt:                      ; Label to increment positive count
	inc byte[pcount]        ; Increment positive count
	
cont:                      ; Label to continue to next number
	loop nextnum            ; Loop for next number


; for display number in hexdeimal form

	mov rsi, hexnum         ; Reset array pointer
	mov rcx, 5              ; Reset loop counter
	
next2:
	push rcx                ; Save loop counter
	push rsi                ; Save array pointer
	
	mov rbx, [rsi]          ; Load number from array
	call display            ; Display the number
	
	pop rsi                 ; Restore array pointer
	pop rcx                 ; Restore loop counter
	add rsi, 8              ; Move to next element in array
	
	loop next2              ; Loop for next number
	
	write endl, 1           ; Print newline
    

; for display nnumber of positive number
    
	mov bl, [pcount]        ; Load positive count into bl
	call display8           ; Display positive count
	
	write endl, 1           ; Print newline
    

; for display nnumber of negative number

	mov bl, [ncount]        ; Load negative count into bl
	call display8           ; Display negative count
	
	mov rax, 60             ; Exit syscall number
	mov rsi, 0              ; Exit code
	syscall                 
    

; Procedure to convert ASCII input to hexadecimal
ascii_hex:
	mov rbx, 0              ; Clear rbx (hexadecimal result)
	mov rsi, num1           ; Pointer to ASCII input
	mov rcx, 16             ; Loop 16 times (for each digit)
next:
	rol rbx, 4              ; Rotate left by 4 bits (1 nibble)
	mov al, [rsi]           ; Load ASCII character
	cmp al, '9'             ; Check if it's less than or equal to '9'
	jbe sub30h              ; If yes, jump to subtraction
	sub al, 7h              ; Otherwise, subtract 7 to convert from 'A' to 'F'
sub30h:                    ; Label to subtract '0'
	sub al, 30h             ; Subtract '0' to get hexadecimal value
	add bl, al              ; Add to result in rbx
	inc rsi                 ; Move to next character
	loop next               ; Repeat for each digit
	ret                      ; Return

; Procedure to display hexadecimal number
display:
	mov rsi, temp            ; Pointer to temporary storage
	mov rcx, 16             ; Loop 16 times (for each digit)
next1:
	rol rbx, 4              ; Rotate left by 4 bits (1 nibble)
	mov al, bl              ; Load current nibble
	and al, 0Fh             ; Mask upper bits to get only lower 4 bits
	cmp al, 9               ; Check if it's greater than 9
	jbe add30h              ; If not, jump to addition
	add al, 7h              ; Otherwise, add 7 to convert from 10-15 to 'A' to 'F'
add30h:                    ; Label to add '0'
	add al, 30h             ; Add '0' to get ASCII value
	mov [rsi], al           ; Store in temporary storage
	inc rsi                 ; Move to next character
	loop next1              ; Repeat for each digit
	write temp, 16          ; Display the hexadecimal number
	write endl, 1           ; Print newline
	ret                      ; Return

; Procedure to display a single byte (8 bits)
display8:
	mov rsi, temp            ; Pointer to temporary storage
	mov rcx, 2              ; Loop 2 times (for 2 hexadecimal digits)
next18:
	rol bl, 4                ; Rotate left by 4 bits (1 nibble)
	mov al, bl               ; Load current nibble
	and al, 0Fh              ; Mask upper bits to get only lower 4 bits
	cmp al, 9                ; Check if it's greater than 9
	jbe add30h8              ; If not, jump to addition
	add al, 7h               ; Otherwise, add 7 to convert from 10-15 to 'A' to 'F'
add30h8:                     ; Label to add '0'
	add al, 30h              ; Add '0' to get ASCII value
	mov [rsi], al            ; Store in temporary storage
	inc rsi                  ; Move to next character
	loop next18              ; Repeat for each digit
	write temp, 2            ; Display the hexadecimal number
	write endl, 1            ; Print newline
	ret                       ; Return
