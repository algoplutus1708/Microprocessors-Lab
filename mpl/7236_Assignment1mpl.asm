; ALP to accept five 64-bit hexadecimal numbers from the user and store them
; Name: Navjot Singh

; Define a macro 'io' for making system calls with parameters
%macro io 4               ;predefine instruction
       mov rax, %1        ; System call number
       mov rdi, %2        ; File descriptor (stdout: 1, stdin: 0)
       mov rsi, %3        ; Pointer to the message or data
       mov rdx, %4        ; Length of the message or data
       syscall
%endmacro

section .data
        msg1 db "ALP to display five 64-bit hexadecimal numbers", 10
        msg1len equ $-msg1
        
        msg2 db "Enter five 64-bit hexadecimal numbers", 10
        msg2len equ $-msg2
        
        msg3 db "Five 64-bit hexadecimal numbers are", 10
        msg3len equ $-msg3
        
        newline db 10

section .bss 
        num resb 17        ; Buffer to store user input as ASCII,byte
        hexnum resq 5       ; Array to store five 64-bit hexadecimal numbers
        temp resb 16        ; Temporary buffer for ASCII conversion

section .text
global _start

_start:
       io 1, 1, msg1, msg1len   ; Display the program's introduction message
       io 1, 1, msg2, msg2len   ; Display the message to input five hexadecimal numbers
       mov rcx, 5               ; Set the loop counter to 5
       mov rsi, hexnum          ; Set the destination pointer for storing hexadecimal numbers

next:
       push rsi                 ; Save the destination pointer
       push rcx                 ; Save the loop counter
       io 0, 0, num, 17         ; Read user input as ASCII
       call ascii_hex           ; Convert ASCII to hexadecimal
       pop rcx                  ; Restore the loop counter
       pop rsi                  ; Restore the destination pointer
       mov [rsi], rbx           ; Store the converted hexadecimal number
       add rsi, 8               ; Move to the next slot in the array
       
loop next

       io 1, 1, msg3, msg3len   ; Display the message indicating the entered numbers

       mov rcx, 5               ; Set the loop counter to 5
       mov rsi, hexnum          ; Set the source pointer for the stored hexadecimal numbers

next1:
       push rsi                 ; Save the source pointer
       push rcx                 ; Save the loop counter
       mov rbx, [rsi]           ; Load the hexadecimal number
       call hex_ascii          ; Convert hexadecimal to ASCII
       pop rcx                  ; Restore the loop counter
       pop rsi                  ; Restore the source pointer
       add rsi, 8               ; Move to the next slot in the array
loop next1

       mov rax, 60              ; Exit system call number
       mov rdi, 0               ; Exit status 0
       syscall

; ASCII to Hexadecimal conversion subroutine
ascii_hex:
       mov rcx, 16              ; Set the loop counter to 16 (length of hexadecimal)
       mov rsi, num             ; Set the source pointer to the ASCII input
       mov rbx, 0               ; Initialize the result register to 0

nextdigit:
       rol rbx, 4               ; Rotate the result register by 4 bits
       mov al, [rsi]            ; Load the current ASCII character
       cmp al, 39h              ; Compare with ASCII character '9'
       jbe sub30h               ; Jump if less than or equal to '9'
       sub al, 7h               ; Adjust for letters (A-F)

sub30h:
       sub al, 30h              ; Convert ASCII to binary
       add bl, al               ; Add to the result
       inc rsi                  ; Move to the next character
loop nextdigit
       ret

; Hexadecimal to ASCII conversion subroutine
hex_ascii:
       mov rcx, 16              ; Set the loop counter to 16 (length of hexadecimal)
       mov rsi, temp            ; Set the destination pointer for ASCII output

next_num:
        rol rbx, 4              ; Rotate the result register by 4 bits
        mov al, bl              ; Extract the lower 4 bits
        and al, 0Fh             ; Mask upper bits
        cmp al, 9               ; Compare with 9
        jbe add30h              ; Jump if less than or equal to 9
        add al, 7h              ; Adjust for letters (A-F)

add30h:
        add al, 30h             ; Convert to ASCII
        mov [rsi], al           ; Store the ASCII character
        inc rsi                 ; Move to the next character
loop next_num
        io 1, 1, temp, 16       ; Display the converted ASCII string
        io 1, 1, newline, 1     ; Display a newline character
        ret

