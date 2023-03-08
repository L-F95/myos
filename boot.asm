[org 0x7c00]

mov ax,3
int 0x10

mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
mov ss,ax
mov sp,0x7c00

; 显存映射区


mov si,bootmess
call print

mov edi,0x1000  ; 读取位置
mov ecx,2 ; 起始扇区
mov bl,4  ; 扇区数
call read_disk

cmp word [0x1000], 0x55aa
    jnz error

jmp 0:0x1002
; xchg bx,bx 魔术断点


read_disk:
    mov dx,0x1f2
    mov al, bl
    out dx, al
    
    inc dx  ; 0x1f3
    mov al,cl ;起始扇区的前八位
    out dx,al
    
    inc dx  ; 0x1f4
    shr ecx,8
    mov al,cl ;起始扇区的中八位
    out dx,al

    inc dx  ; 0x1f5
    shr ecx,8
    mov al,cl ;起始扇区的高八位
    out dx,al

    inc dx  ; 0x1f6
    shr ecx,8
    and cl,0b1111  ;高4位置为0
    
    mov al,0b1110_0000
    or al,cl
    out dx,al  ;LBA

    inc dx
    mov al,0x20
    out dx,al  ;读硬盘

    xor ecx,ecx
    mov cl,bl
    .read:
        push cx
        call .waits
        call .reads
        pop cx
        loop .read
    ret

    .waits:
        mov dx,0x1f7
        .check:
            in al,dx
            jmp $+2
            jmp $+2
            jmp $+2
            and al,0b1000_1000
            cmp al,0b0000_1000
            jnz .check
        ret
    .reads:
        mov dx,0x1f0
        mov cx,256
        .readw:
            in ax,dx
            jmp $+2
            jmp $+2
            jmp $+2
            mov [edi], ax
            add edi,2
            loop .readw
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


error:
    mov si,.msg
    call print
    hlt
    jmp $
    .msg db "booting error...",10,13,0
bootmess:
    db "booting lfsos ...", 10, 13, 0 ; \n \r \0
times 510 -($-$$) db 0
db 0x55,0xaa
