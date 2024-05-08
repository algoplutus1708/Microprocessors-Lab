; ALP to accept string and display its length.
; Name: Navjot Singh

; Macro definition for input/output with 4 parameters
%macro io 4
    mov rax, %1           ; System call number
    mov rdi, %2           ; File descriptor (stdout: 1, stdin: 0)
    mov rsi, %3           ; Pointer to the message or data
    mov rdx, %4           ; Length of the message or data
    syscall
%endmacro

section .data
    msg1 db "ALP to accept string and display its length ", 10 ; Message about the program
    msg1len equ $ - msg1                                        ; Length of msg1
    
    msg2 db "Enter String : ", 10                                ; Prompt for user input
    msg2len equ $ - msg2                                        ; Length of msg2
    
    msg3 db "Length is : ", 10                                   ; Message for displaying length
    msg3len equ $ - msg3                                        ; Length of msg3
    
    newline db 10                                               ; Newline character

section .bss
    len resb 1                                                  ; Variable to store the length
    temp resb 2                                                 ; Temporary buffer for ASCII conversion
    str1 resb 20                                                ; Buffer to store the entered string

section .text

global _start

_start:
    io 1, 1, msg1, msg1len     ; Display introductory message
    io 1, 1, msg2, msg2len     ; Prompt user to enter a string
    io 0, 0, str1, 20           ; Read the string from the user into str1
    
    dec rax                    ; Subtract 1 from rax (not necessary as it is not used)
    mov [len], rax             ; Store the length (0) in len
    
    mov bl, [len]              ; Load the length into bl
    call hex_ascii8            ; Convert the length to hex and display
    
    mov rax, 60                ; Exit system call number
    mov rdi, 0                 ; Exit status 0
    syscall

hex_ascii8:
    mov rcx, 2                 ; Set the loop counter to 2 (length of temp buffer)
    mov rsi, temp              ; Set the destination pointer for hex conversion

nextnum:
    rol bl, 4                  ; Rotate the bits in bl by 4 positions
    mov al, bl                 ; Move the lower 4 bits of bl to al
    and al, 0fh                ; Mask upper bits of al
    
    cmp al, 9                  ; Compare al with 9
    jbe add30h                 ; Jump if less than or equal to 9
    
    add al, 7h                 ; Adjust for letters (A-F)

add30h:
    add al, 30h                ; Convert the value in al to ASCII
    mov [rsi], al              ; Store the ASCII character in temp buffer
    inc rsi                    ; Move to the next position in the buffer
    loop nextnum               ; Repeat the loop until rcx becomes zero

    io 1, 1, msg3, msg3len     ; Display "Length is : "
    io 1, 1, temp, 2           ; Display the converted length
    io 1, 1, newline, 1         ; Display a newline character
    ret                         ; Return from the subroutine

