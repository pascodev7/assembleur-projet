;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Devoir assembleur de Pascal Jeanty consistant a demander   ;
; a un utilisateur d'entrer une chaine de caractere puis un  ;
; nombre et ensuite le programme recherche ce nombre dans la ;
; chaine de caracteres                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




org 100h

.data
buf1 DB "Enter String :::: $"
buf2 DB 0dh,0ah,"Enter the number to search :::: $"
buf3 DB 0dh,0ah,"Number Found $",1
buf4 DB 0dh,0ah,"Number not Found...$"
str DB 120,120 DUP(?)
str_len DW 0
substr DB 120,120 DUP (?)
substr_len DW 0
counter DW 0  


; this macro prints a char in AL and advances
  ; the current cursor position:
  putc  macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
  endm 

.code

;initilize Data Segment
mov ax,@DATA
mov DS,ax

;==========Input String=====
lea dx,buf1
call display
mov dx,offset str
mov ah,0Ah
int 21h
mov bl,[str+1]
mov str_len,bx

;=======Input Substring======
lea dx,buf2
call display  
;call SCAN_NUM
mov dx,offset substr
mov ah,0Ah          
;call SCAN_NUM
int 21h

;checking if substring(number) is in string or not
lea SI,str ;SI contain String
add SI,2
lea DI,substr ;DI contain substring
add DI,2
mov bx,substr_len
cmp str_len,bx
jg G ;CX will contain greater value
mov cx,bx

G:
mov cx,str_len

;======Cheking if substring or not====
L:
lodsb
cmp al,0Dh
je final
cmp al,' '
jne next

final:
cmp counter,0
je exit
mov counter,0
lea DI,substr
add DI,2
jmp next1

next:
dec SI

next1:
cmpsb
je h
inc counter
h:
LOOP L

exit:
cmp counter,0
je Found
lea dx,buf4
call Display
jmp terminate

Found:
lea dx,buf3
call Display

terminate:
;to terminate program
mov ah,4ch
int 21h
ret 

Display PROC
mov ah,09h
int 21h
ret
Display ENDP   






                
                
                
                
                
                
                
                
                
                
                
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;L'utilisateur saisit un nombre     
  ; wait for any key....
         
       SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:           
        MOV     BX,10
        DIV     BX                      ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX  
        MOV     BX, 10
        MUL     BX                  ; DX:AX = AX*10
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        MOV     BX,10
        DIV     BX          ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.  

SCAN_NUM        ENDP 


   
           
;END           