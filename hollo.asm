 org 0x7C00   ; add 0x7C00 to label addresses
 bits 16      ; tell the assembler we want 16 bit code
 
   mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00
 
   mov si, welcome
   call print_string
 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; yes, ignore it
 
   mov si, buffer
   mov di, cmd_hi  ; "yori"
   call strcmp
   jc .helloworld
 
   mov si, buffer
   mov di, cmd_help  ; "help"
   call strcmp
   jc .help
   
   mov si, buffer
   mov di, cmd_die
   call strcmp
   jc .end_me
   
   mov si, buffer
   mov di, cmd_author
   call strcmp
   jc .author
 
   mov si,badcommand
   call print_string 
   jmp mainloop  
   
 
 .helloworld:
   mov si, msg_helloworld
   call print_string
 
   jmp mainloop
   
 .end_me:
 mov ah,0x4c
 int 0x21
 jmp mainloop
 
 .help:
   mov si, msg_help
   call print_string
 
   jmp mainloop
   
   .author:
   mov si, msg_author
   call print_string
   
   jmp mainloop
 
 welcome db 'Welcome to HolOS!', 0x0D, 0x0A, 0
 msg_helloworld db 'I love yori ^-^', 0x0D, 0x0A, 0
 badcommand db 'Wrong command dumbass.', 0x0D, 0x0A, 0
 prompt db '$', 0
 cmd_hi db 'yori', 0
 cmd_die db 'exit', 0
 cmd_help db 'help', 0
 msg_help db 'HolOS: Commands: yori, help, exit, author', 0x0D, 0x0A, 0
 cmd_author db 'author',0
 msg_author db 'Made by Holo. <holothenotsowise@gmail.com>', 0x0D,0x0A,0
 buffer times 64 db 0


 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope
 
   cmp al, 0  ; bytes eq?
   je .done 
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret
 
   times 510-($-$$) db 0
   dw 0AA55h 