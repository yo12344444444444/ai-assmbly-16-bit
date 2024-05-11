IDEAL
MODEL huge
STACK 100h
DATASEG
    enemyMidelCord dw 1, 160, 100 
    foodP dw 0, 5, 5, 0, 10
         dw 5, 5, 5, 5, 10
         dw 5, 5, 5, 5, 10
         dw 0, 5, 5, 0, 11
    inputSize dw 3
    num dw ?
    killPlcae dw 300
    place db 100
    sizeOffKiller dw 100
    hiddenSize dw 9
    outputSiz dw 1
    ErrorMsg db "error"
    Filename db "file.txt",0
    filehandle dw ? 

SEGMENT hiddenSeg
input dw 3 dup(0)
wights db 9,1,23
wights2 db 1,2,3,4
ENDS hiddenSeg
SEGMENT outputSeg
    dw 2000 dup(?)
ENDS outputSeg
CODESEG
proc wait
    push ax
    push cx
    mov ah, 86h  ; AH = 86h for the DOS function "Wait"
    mov cx, 1   ; CX = 5, number of milliseconds to wait
    int 15h      ; Invoke interrupt 15h to wait
    pop cx
    pop ax
    ret
endp wait
proc OpenFile
    ; Open file
    mov ah, 3Dh
    xor al, al
    lea dx, [filename]
    int 21h
    jc openerror
    mov [filehandle], ax
    ret
    openerror:
        mov dx, offset ErrorMsg
        mov ah, 9h
        int 21h
        ret
endp OpenFile
proc drowkiller
    push ax
    push cx
    push di
    push dx
    mov dx , 175
    sub dx , [offset sizeOffKiller]
    mov di, [offset killPlcae]
    add di , 5
    mov cx ,0
    mov ax , 0
    rowe:
        inc cx
        add di, 320
        sub di , ax
        mov ax ,0
        colome:
            inc ax
            inc di
            mov [es:di] , 0
            cmp ax , 10
            jnz colome
        cmp cx , [sizeOffKiller] 
        jnz rowe
    mov di, 320*200
    add di , [offset killPlcae]
    add di , 5
    mov cx ,0
    mov ax , 0
    rowss:
        inc cx
        sub di, 320
        sub di , ax
        mov ax ,0
        colomss:
            inc ax
            inc di
            mov [es:di] , 0
            cmp ax , 10
            jnz colomss
        cmp cx , dx
        jnz rowss
    mov dx , 175
    sub dx , [offset sizeOffKiller]
    mov di, [offset killPlcae]
    mov cx ,0
    mov ax , 0
    row:
        inc cx
        add di, 320
        sub di , ax
        mov ax ,0
        colom:
            inc ax
            inc di
            mov [es:di] , 2
            cmp ax , 10
            jnz colom
        cmp cx , [sizeOffKiller] 
        jnz row
    mov di, 320*200
    add di , [offset killPlcae]
    mov cx ,0
    mov ax , 0
    rows:
        inc cx
        sub di, 320
        sub di , ax
        mov ax ,0
        coloms:
            inc ax
            inc di
            mov [es:di] , 2
            cmp ax , 10
            jnz coloms
        cmp cx , dx
        jnz rows
    pop dx
    pop di
    pop cx
    pop ax
    ret 
endp drowkiller
proc drowPlayer
    push ax
    push cx
    push di
    mov al, [byte offset place]
    mov cl , 200
    mul cl
    mov di , ax
    mov cx ,0
    mov ax , 0
    row3:
        inc cx
        add di, 320
        sub di , ax
        mov ax ,0
        colom3:
            inc ax
            inc di
            mov [es:di] , 5
            cmp ax , 5
            jnz colom3
        cmp cx , 5
        jnz row3
    pop di
    pop cx
    pop ax
    ret 
endp drowPlayer
proc ReadFile
    push ax
    push cx
    push cx
    mov ah,3Fh
    mov bx, [offset filehandle]
    mov cx,1
    mov dx,offset num
    int 21h
    ret
    pop bx
    pop cx
    pop ax
    ret
endp ReadFile 
proc readNN
    push si
    push di
    push bx
    push cx
    push ax
    push dx
    push es
    push ds
    ;    mov cx , [offset hiddensize]
    mov dx , [offset inputSize]
    add cx , dx
    mov ax, hiddenSeg
    mov ds, ax
    mov ax , outputSeg
    mov es , ax
    mov si , 0
    mov di ,0
    mov ax , 0
    outputLoop:
        cmp di ,1
        jz outputLoops
        hiddenLoop:
            add al, [byte offset di] 
            mov ah, [byte ptr offset wights+si]
            mul ah
            add [es:di] , ax
            inc si
            cmp si , dx
            jnz hiddenLoop
        inc di
        jmp outputLoop
    outputLoops:
    pop ds
    pop es
    pop dx
    pop ax
    pop cx
    pop bx
    pop di
    pop si
    ret
endp readNN
proc move
    push ax
    push cx
    push di
    push es
    mov ax ,0
    mov al, [byte offset place] 
    mov cl , 200
    mul cl
    mov di , ax
    mov ax, outputSeg
    mov es, ax
    mov si , [es:0]
    cmp si, 8800
    jle up
    ja down 
    down:     
        cmp [byte offset place], 220
        je action
        add [byte offset place] , 8
        jmp action 
    up:
        cmp [byte offset place], 60
        je action
        sub [byte offset place] , 8
    action: 
        ;jmp ene
        mov cx ,0
        mov ax , 0
        row2:
            inc cx
            add di, 320
            sub di , ax
            mov ax ,0
            colom2:
                inc ax
                inc di
                mov [es:di] , 0
                cmp ax , 5
                jnz colom2
            cmp cx , 5
            jnz row2
        sub [offset killPlcae], 5
    ene:
    pop es
    pop di
    pop cx
    pop ax
    ret 
endp move
proc discigoin
    push ax
    push di 
    push es
    push bx
    mov ax, hiddenSeg
    mov es, ax
    mov di , 0 
    mov al , [byte offset place]
    mov [es:di] , al
    add di , 2
    mov ax , [offset sizeOffKiller]
    mov [es:di], ax 
    mov ax , 275 
    sub ax , [offset sizeOffKiller]
    add di , 2
    mov [es:di], ax 
    pop bx
    pop es
    pop di 
    pop ax  
    ret
endp discigoin
start:
    mov ax, @data
    mov ds, ax
    mov ax, 13h
    int 10h
    mov ax, 0A000h 
    mov es, ax
inf:
    call discigoin
    call readNN
    call move
    call drowkiller
    call drowPlayer
    call wait
    MOV AH, 00h
    INT 16h
    CMP AL, ' '
    ;JE jump
    jne inf
jump:

    MOV AH, 00h
    INT 16h
    call move
    jmp inf

exit:
    mov ax, 4c00h
    int 21h
END start
