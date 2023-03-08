[org 0x1000]

dw 0x55aa

xchg bx,bx
mov si,loadmess
call print


jmp $

 
print:
    mov ah,0x0e
.next:
    mov al,[si]
    cmp al,0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
loadmess:
    db "loading lfsos ...", 10, 13, 0 ; \n \r \0