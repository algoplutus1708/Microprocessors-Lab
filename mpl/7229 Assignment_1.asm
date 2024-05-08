;Write an X86/64 ALP to accept five 64 bit Hexadecimal numbers from user and store them in an array and display the accepted numbers.


%macro io 4          ; Define a macro 'io' with 4 parameters
    mov rax ,%1      ; Move the value of the first parameter into the rax register
    mov rdi, %2      ; Move the value of the second parameter into the rdi register
    mov rsi, %3      ; Move the value of the third parameter into the rsi register
    mov rdx, %4      ; Move the value of the fourth parameter into the rdx register
    syscall          ; Invoke the system call
%endmacro

section .data        ; Define the data section
    msg1 db "Number : "  ; Define a message "Number : " in the data section
    msg1len equ $ - msg1  ; Calculate the length of the message
    endl db 10         ; Define a newline character in the data section

section .bss         ; Define the bss section
    hexnum resq 5     ; Reserve space for 5 quadwords (64-bit integers) for hex numbers
    num1 resb 17      ; Reserve space for 17 bytes for storing input numbers as ASCII
    temp resb 16      ; Reserve space for 16 bytes for temporary storage

section .text        ; Define the text section
    global _start    ; Define the entry point of the program as _start

_start:              ; Start of the program

    mov rcx, 5       ; Move the value 5 into the rcx register (counter for loop iterations)
    mov rsi, hexnum  ; Move the address of hexnum into the rsi register (pointer to hex numbers)
nextnum:             ; Label for the loop
    push rcx         ; Save the value of rcx onto the stack
    push rsi         ; Save the value of rsi onto the stack
    io 0,0,num1,17   ; Read input number as ASCII
    call ascii_hex   ; Convert ASCII input to hexadecimal
    pop rsi          ; Restore the value of rsi from the stack
    pop rcx          ; Restore the value of rcx from the stack
    mov [rsi], rbx   ; Store the hexadecimal value in hexnum
    add rsi, 8       ; Move to the next 64-bit space in hexnum
    loop nextnum     ; Continue looping until rcx becomes zero


    mov rsi, hexnum  ; Move the address of hexnum into the rsi register
    mov rcx, 5       ; Move the value 5 into the rcx register (counter for loop iterations)
next2:               ; Label for the second loop
    push rcx         ; Save the value of rcx onto the stack
    push rsi         ; Save the value of rsi onto the stack
    mov rbx, [rsi]   ; Move the hexadecimal value from memory to rbx
    call display     ; Display the hexadecimal value
    pop rsi          ; Restore the value of rsi from the stack
    pop rcx          ; Restore the value of rcx from the stack
    add rsi, 8       ; Move to the next 64-bit space in hexnum
    loop next2       ; Continue looping until rcx becomes zero

    mov rax, 60      ; Move the value 60 (exit syscall number) into rax
    mov rsi, 0       ; Move the value 0 into rsi (exit status)
    syscall           ; Invoke the system call to exit
    
    
ascii_hex:           ; Start of the function ascii_hex
    mov rbx, 0       ; Clear rbx register (initialize to zero)
    mov rsi, num1    ; Move the address of num1 (ASCII input) into rsi
    mov rcx, 16      ; Move the value 16 into rcx (loop counter)
next:                ; Label for the loop
    rol rbx, 4       ; Rotate the bits in rbx to the left by 4 bits
    mov al, [rsi]    ; Move the byte from the memory address in rsi into al (ASCII character)
    cmp al, '9'      ; Compare al with '9'
    jbe sub30h       ; Jump to sub30h if al is less than or equal to '9'
    sub al, 7h       ; Subtract 7h from al (convert uppercase letters to their corresponding values)
sub30h:             ; Label for subtracting '0'
    sub al, 30h      ; Subtract 30h from al (convert ASCII to integer)
    add bl, al       ; Add the value in al to bl (accumulate hexadecimal value)
    inc rsi          ; Increment rsi to point to the next ASCII character
    loop next        ; Continue looping until rcx becomes zero
    ret              ; Return from the function
    
    

display:             ; Start of the function display
    mov rsi, temp    ; Move the address of temp (temporary storage) into rsi
    mov rcx, 16      ; Move the value 16 into rcx (loop counter)
next1:               ; Label for the loop
    rol rbx, 4       ; Rotate the bits in rbx to the left by 4 bits
    mov al, bl       ; Move the lower 8 bits of rbx into al
    and al, 0Fh      ; Bitwise AND operation with 0Fh to get the lower 4 bits
    cmp al, 9        ; Compare al with 9
    jbe add30h       ; Jump to add30h if al is less than or equal to 9
    add al, 7h       ; Add 7h to al (convert integer to uppercase letter)
add30h:             ; Label for adding '0'
    add al, 30h      ; Add 30h to al (convert integer to ASCII)
    mov [rsi], al    ; Move the value in al to the memory address in rsi
    inc rsi          ; Increment rsi to point to the next byte in temp
    loop next1       ; Continue looping until rcx becomes zero
    io 1,1,msg1,msg1len  ;print msg1
    io 1,1,temp,16   ; Print the hexadecimal number stored in temp
    io 1,1, endl,1   ; Print a newline character
    ret              ; Return from the function


; 123456789ABCDEF0
; A5F0E1D2C3B4A798
; 6F2A8B1C3D4E5F09
; DEADBEEFCAFEBABE
; 87654321ABCDEF12