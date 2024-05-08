; Define macro for input/output operations
%macro io 4
    mov rax, %1   ; Syscall number
    mov rdi, %2   ; File descriptor (0 for stdin, 1 for stdout)
    mov rsi, %3   ; Pointer to data buffer
    mov rdx, %4   ; Length of data
    syscall       ; Invoke syscall
%endmacro

section .data
    msg1 db "Enter string",10    ; Message to prompt user to enter string
    msg1len equ $-msg1           ; Length of the prompt message
    msg2 db "Entered",10         ; Message to inform user that input has been entered
    msg2len equ $-msg2           ; Length of the "Entered" message
    msg3 db "length is",10       ; Message to indicate the length of the string
    msg3len equ $-msg3           ; Length of the "length is" message

    newline db 10                ; Newline character

section .bss
    str1 resb 20                 ; Buffer to store the entered string
    len resb 1                   ; Buffer to store the length of the string
    temp resb 2                  ; Temporary buffer for hexadecimal conversion

section .text
global _start

_start:
    ; Prompt the user to enter a string
    io 1, 1, msg1, msg1len
    io 1, 1, msg2, msg2len

    ; Read the string from the user
    io 0, 0, str1, 20            ; Assuming maximum length of input is 20 bytes

    dec rax                      ; RAX holds the length of the input including newline character
    mov [len], rax               ; Store the length of the string

    mov bl, byte [len]           ; Move the length to BL register for manipulation
    call hex_ascii8              ; Call the function to convert length to hexadecimal

    io 1, 1, temp, 2             ; Display the hexadecimal length
    io 1, 1, newline, 1          ; Newline for formatting

    mov rax, 60                  ; Exit syscall number
    mov rdi, 0                   ; Exit status
    syscall                      ; Invoke syscall

; Function to convert a byte value to hexadecimal ASCII
hex_ascii8:
    mov rcx, 2                   ; Number of iterations (2 hexadecimal digits)
    mov rsi, temp                ; Pointer to the temporary buffer

nextnum:
    rol bl, 4                    ; Rotate left to get next nibble
    mov al, bl                   ; Move the value to AL register
    and al, 0fh                  ; Mask to keep only the lower 4 bits (nibble)
    cmp al, 9                    ; Check if the value is less than or equal to 9
    jbe add30h                   ; Jump if less than or equal to 9
    add al, 7h                   ; Adjust value for ASCII conversion
add30h:
    add al, 30h                  ; Convert the value to ASCII
    mov [rsi], al                ; Store the ASCII character in the buffer
    inc rsi                      ; Move to the next byte in the buffer
    loop nextnum                 ; Loop until all nibbles are processed
    ret                          ; Return from the function
