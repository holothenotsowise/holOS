org 0x7c00
bits 16

mov ax,0     ;Move 0 to ax
mov ds, ax   ;Move ax to ds
mov es, ax    ;Move ax to es
mov ss, ax     ;move ax to ss
mov sp, 0x7c00 ;move 0x7c00 to sp

mov si, greeting    ;move greeting to si
call print_string     ;call print string


mainloop:         ;our main loop woop
mov si,prompt ;move the promt to si
call print_string ; Call that string up


mov si, buffer ;Move the buffer here too
cmp byte [si], 0
je mainloop  ; If it is blank we go back to the main loop without throwing a invalid bad cmd

mov si, buffer
mov di, cmd_yori  ;"yori" command for waifu
call strcmp 
jc .yoricmd

mov si, buffer
mov di, cmd_help ; This is my help command. I am a helpful Holo ^-^
call strcmp
jc .help 

mov si, buffer 
mov di, cmd_version ;Version status 
call strcmp
jc .version

mov si, buffer
mov di, cmd_author
call strcmp
jc .author

mov si, buffer
mov di, cmd_endme    ; Most of these are fun commands but this one actually ends the program
call strcmp 
jc .endme

mov si, badcmd
call print_string
jmp mainloop


.yoricmd:
mov si, msg_yoricmd
call print_string

jmp mainloop

.help:
mov si, msg_help
call print_string 

jmp mainloop

.version:
mov si, msg_version
call print_string

jmp mainloop

.author:
mov si,msg_author
call print_string
jmp mainloop

.endme:
mov ah, 0x4c
int 0x21

; my strings 

greeting db 'Welcome to HolOS! Type help for more!', 0x0D, 0x0A, 0
badcommand db 'ERROR! INVALID INPUT',  0x0D,0x0A,0
cmd_yori db 'yori', 0
cmd_help db 'help', 0
cmd_author db 'author', 0
cmd_version db 'version', 0
cmd_endme db 'exit', 0
msg_help db 'Commands => help, yori, author, version, exit',  0x0D,0x0A,0
msg_author db 'Made by Holo. <holothenotsowise@gmail.com>', 0x0D,0x0A,0
msg_version db 'Version 1.0.0',  0x0D,0x0A,0
msg_yoricmd db 'I love yori ^-^',  0x0D,0x0A,0
buffer times 64 db 0

;time for some calls


print_string ; Remember me?
	lodsb ; Grab a byte from SI
	
	or al, al ; Some logic
	jz .done ;If the result is zero get out
	
	mov ah, 0x0e
	int 0x10 ;else print out the character
	
	jmp print_string
	
	.done:
	ret
	
	get_string;
	xor cl,cl
	
	.loop:
	mov ah, 0
	int 0x16 ;Wait for keypress. Keep waiting. Wait some more
	
	cmp al, 0x08 ; Was there a backspace?
	je .backspace ; Ye. Handle it now
	
	cmp al, 0x0D ;Enter pressed?
	je .done ; Yep we done here
	
	cmp cl, 0x3F ;63 chars input?
	je .loop ; if so only allow backspace and enter
	
	mov ah, 0x0E
	int 0x10 ;print
	
	stosb ;Char in buffer
	inc cl 
	jmp .loop
	
.backspace:
cmp cl, 0 ; Beginning of string???
je .loop ; If yeah ignore the key

dec di
mov byte [di], 0 ;Delete char
dec cl  ;decrease counter 

mov ah, 0x0E
mov al 0x08
int 10h ;Show the backspace on screen

mov al, ' ' 
int 10h ;Blank out char

mov al, 0x08 
int 10h

jmp .loop

.done: 
mov al,0
stosb

mov ah 0x0E
mov al, 0x0D
int 0x10
mov al, 0x0A
int 0x10

ret

strcmp:
.loop
mov al, [si]
mov bl, [di]
cmp al,bl
jne .notequal

cmp al, 0
je.done

inc di
inc si
jmp .loop

.notequal:
clc
ret

.done:
stc
ret

times 510-($-$$) db 0
dw 0AA55H

.