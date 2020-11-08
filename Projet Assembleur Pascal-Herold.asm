;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ETUDIANTS: Pascal Jeanty, Herold Desir, Jefferson Sainrilis
; projet de fin de cours assembleur # 5
; entrer deux nombres decimaux, les convertir en binaire
; afficher leur somme et leur difference en binaire et en decimal
; Recommencer ce meme processus en BCD
; afficher la division entiere du premier nombre par le deuxieme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org 100h

jmp debut

   count db 0
   result db 16 dup('?'),'b'
   

msg1 db "Veuillez saisir un nombre,SVP : $", 0Dh,0Ah

msg2 db 0Dh,0Ah, "Le nombre en binaire est: $"
msg3 db 0Dh,0Ah, "Veuillez saisir un deuxieme nombre, SVP : $"
msg4 db 0Dh,0Ah, "Le nombre en binaire est: $" 
msg5 db 0Dh,0Ah, "Leur somme en decimal est: $" 
msg6 db 0Dh,0Ah, "Leur somme en en binaire est: $" 
msg7 db 0Dh,0Ah, "La difference en decimal est: $"
  
msg8 db 0Dh,0Ah, "La difference en en binaire est: $" 
msg9 db 0DH,0AH, "La division de ces deux nombre est: $" 
CRLF           DB 13,10,'$'
nb   dw ?
nbb  dw ?
d2   dw ?
   c dw ?

debut:


;conversion binaire.


mov dx, offset msg1
mov ah, 9
int 21h


call scan_num

mov bx, cx
mov nb, bx
call convert_to_bin

mov dx, offset msg2
mov ah, 9
int 21h

mov si, offset result
mov ah, 0eh
mov cx, 17
print_me:
mov al, [si]
int 10h
inc si
loop print_me


   mov dx, offset msg3
   mov ah, 9
   int 21h 
   
   call scan_num

mov bx, cx
mov nbb, bx
call convert_to_bin

   
   mov dx, offset msg4
   mov ah, 9
   int 21h 
   
   mov si, offset result
  mov ah, 0eh
  mov cx, 17
 print_mee:
 mov al, [si]
 int 10h
 inc si
 loop print_mee

   mov dx, offset msg5
   mov ah, 9
   int 21h
   
    
    mov ax,nb
    mov bx,nbb
    add ax, bx
     mov d2,ax
 
       ;mov dx, ax
            mov bx,10   
            while:
            xor dx, dx
            cmp ax, 0
            je fin:
            div bx
            push dx
            inc count
            jmp while
            fin:
            
            mov cl, count
            xor dx, dx
            l1:
            pop dx
            mov al, dl
            add al, '0'
            mov ah, 0eh
            int 10h
            
            loop l1 
    
            
     mov dx, offset msg6
     mov ah, 9
     int 21h       
     mov ax,d2
         
       
         mov bx,2
         
            mov cx, 10h
            loop1:
            xor dx, dx
            div bx
            push dx
            loop loop1
            
            mov cx, 10h
            xor dx, dx
            loop2:
            pop dx
            mov al, dl
            add al, '0'
            mov ah, 0eh
            int 10h
            
            loop loop2 
            
             
            
 mov dx, offset msg7
     mov ah, 9
     int 21h
     
      mov ax,nb
      mov bx,nbb
      xor dx, dx
      xor cx, cx
      sub ax, bx
      mov c,ax
      
      xor cx, cx
       mov bx, 10     
       mov count, 0
            while6:
            xor dx, dx
            cmp ax, 0
            je fin7:
            div bx
            push dx
            inc count
            jmp while6
            fin7:
            
            mov cl, count
            xor dx, dx
            l13:
            pop dx
            mov al, dl
            add al, '0'
            mov ah, 0eh
            int 10h
            
       
      ;mov dx, offset msg7
      ;mov ah, 9
      ;int 21h
     
           loop l13       
            
         
            
     mov dx, offset msg8
     mov ah, 9
     int 21h
            
             mov ax,c   
            
         mov bx,2
         
            mov cx, 10h
            loop12:
            xor dx, dx
            div bx
            push dx
            loop loop12
            
            mov cx, 10h
            xor dx, dx
            loop22:
            pop dx
            mov al, dl
            add al, '0'
            mov ah, 0eh
            int 10h
            
            loop loop22 
            
                 
           
;La division entiere des nombres            
mov dx, offset msg9
mov ah, 9
int 21h

  mov ax,nb 
  xor dx, dx
   mov cx,nbb
  ; cwd
    div cx  
    call PrintDigit
    mov ah,9                                        ;/
    mov dx, offset CRLF  
    

    int 21h 
    
   ; mov ah, 4ch
    int 10h
    
    

               
       
             
; procedure de conversion au binaire.
                                       
;Afficher le resultat                                       
PrintDigit PROC NEAR
    OR  AX,AX
    JNS Positif    
    PUSH AX
     MOV AH,02h
     MOV DL,'-'
     INT 21h
    POP AX
    NEG AX
Positif:
    MOV BX,10           
    XOR CX,CX
NextDigit:
    XOR DX,DX
    DIV BX
    PUSH DX
     INC CX              
     OR  AX,AX
     JNZ NextDigit
PrintOneDigit: 
    POP AX       
    ADD AL,48           
    MOV DL,AL           
    MOV AH,02h
    INT 21h             
    LOOP PrintOneDigit
    RET
ENDP
                                       
                                       



convert_to_bin proc near
pusha

lea di, result

mov cx, 16
print: mov ah, 2
mov [di], '0'
test bx, 1000_0000_0000_0000b
jz zero
mov [di], '1'
zero: shl bx, 1
inc di
loop print

popa
ret
convert_to_bin endp




putc macro char
push ax
mov al, char
mov ah, 0eh
int 10h
pop ax
endm


scan_num proc near
push dx
push ax
push si

mov cx, 0


mov cs:make_minus, 0

next_digit:


mov ah, 00h
int 16h

mov ah, 0eh
int 10h


cmp al, '-'
je set_minus


cmp al, 13
jne not_cr
jmp stop_input
not_cr:


cmp al, 8
jne backspace_checked
mov dx, 0
mov ax, cx
div cs:ten
mov cx, ax
putc ' '
putc 8
jmp next_digit
backspace_checked:



cmp al, '0'
jae ok_ae_0
jmp remove_not_digit
ok_ae_0:
cmp al, '9'
jbe ok_digit
remove_not_digit:
putc 8
putc ' '
putc 8
jmp next_digit
ok_digit:



push ax
mov ax, cx
mul cs:ten
mov cx, ax
pop ax


cmp dx, 0
jne too_big


sub al, 30h


mov ah, 0
mov dx, cx
add cx, ax
jc too_big2

jmp next_digit

set_minus:
mov cs:make_minus, 1
jmp next_digit

too_big2:
mov cx, dx
mov dx, 0
too_big:
mov ax, cx
div cs:ten
mov cx, ax
putc 8
putc ' '
putc 8
jmp next_digit


stop_input:

cmp cs:make_minus, 0
je not_minus
neg cx
not_minus:

pop si
pop ax
pop dx
ret
make_minus db ?
ten dw 10
scan_num endp  


MOV AH,4CH
INT 21H

  ret    
    