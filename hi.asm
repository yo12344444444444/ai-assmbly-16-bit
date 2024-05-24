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
    place db 150
    sizeOffKiller db 120
    hiddenSize dw 9
    outputSiz dw 1
    ErrorMsg db "error"
    Filename db "file.txt",0
    filehandle dw ? 
    Clock equ es:6Ch
    caunter dw , 0
SEGMENT hiddenSeg
input db 0,0,126
wights db 1,0,1
wights2 db 1,2,3,4
ENDS hiddenSeg
SEGMENT outputSeg
    dw 2000 dup(?)
ENDS outputSeg
CODESEG
proc waite
    push ax
    push cx
    mov ah, 86h  ; AH = 86h for the DOS function "Wait"
    mov cx, 1   ; CX = 5, number of milliseconds to waite
    int 15h      ; Invoke interrupt 15h to waite
    pop cx
    pop ax
    ret
endp waite
proc drowkiller
    push ax
    push cx
    push di
    push dx
    mov dl , 175
    sub dl , [byte offset sizeOffKiller]
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
        cmp cl , [byte offset sizeOffKiller] 
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
    mov dl , 175
    sub dl , [byte offset sizeOffKiller]
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
        cmp cl , [byte offset sizeOffKiller] 
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
        cmp cl , dl
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
    mov [ es:di], 0
    outputLoop:
        cmp di ,3
        jz outputLoops
        hiddenLoop:
            mov al, [byte ptr di] 
            mov ah, [byte ptr offset wights+si]
            mul ah
            add [es:0] , ax
            inc si
            inc di
            cmp si , dx
            jnz hiddenLoop
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
proc newPIP2
    push bx
    mov bx , offset killplcae
    mov [bx], 300 
    mov bx , offset sizeoffkiller
    sub [bx], 30
    pop bx
    ret
endp newPIP2
proc move
    push ax
    push cx
    push di
    push es
    cmp [offset killPlcae], 5
    ja cnc
    call newPIP2
    cnc:
    mov ax ,0
    mov al, [byte offset place] 
    mov cl , 200
    mul cl
    mov di , ax
    mov ax, outputSeg
    mov es, ax
    mov si , [es:0]
    cmp si, 350
    jle down
    ja up
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
        mov ax, 0A000h
        mov es ,ax
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
    inc di 
    mov al , [byte offset sizeOffKiller]
    mov [es:di], al 
    inc di
    mov ax , 275 
    sub al , [byte offset sizeOffKiller]
    mov [es:di], al 
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
    call waite
    jmp inf

exit:
    mov ax, 4c00h
    int 21h
END start
