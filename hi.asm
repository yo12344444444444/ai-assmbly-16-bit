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
    Clock equ es:6Ch
    caunter dw  0
    bise dw  355
    filename db 'bagrond.bmp',0
    filehandle dw ?
    Header db 54 dup (0)
    Palette db 256*4 dup (0)
    ScrLine db 320 dup (0)
    ErrorMsg db 'Error', 13, 10 ,'$'
SEGMENT hiddenSeg
input db 0,0,126
wights db 2,0,2
wights2 db 1,2,3,4
ENDS hiddenSeg
SEGMENT outputSeg
    dw 2000 dup(?)
ENDS outputSeg
SEGMENT bgSeg
    dB 320*200 dup(32)
ENDS bgSeg
CODESEG
proc OpenFile
    ; Open file
    mov ah, 3Dh
    xor al, al
    mov dx, offset filename
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
proc ReadHeader
    ; Read BMP file header, 54 bytes
    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
endp ReadHeader 
proc ReadPalette
    ; Read BMP file color palette, 256 colors * 4 bytes (400h)
    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette
proc CopyPal
    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h
    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0
    ; Copy starting color to port 3C8h
    out dx,al
    ; Copy palette itself to port 3C9h
    inc dx
    PalLoop:
        ; Note: Colors in a BMP file are saved as BGR values rather than RGB .
        mov al,[si+2] ; Get red value .
        shr al,2 ; Max. is 255, but video palette maximal
        ; value is 63. Therefore dividing by 4.
        out dx,al ; Send it .
        mov al,[si+1] ; Get green value .
        shr al,2
        out dx,al ; Send it .
        mov al,[si] ; Get blue value .
        shr al,2
        out dx,al ; Send it .
        add si,4 ; Point to next color 
    loop PalLoop
    ret
endp CopyPal
proc CopyBitmap
    ; BMP graphics are saved upside-down .
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.
    mov ax, bgSeg
    mov es, ax
    mov cx,200
    PrintBMPLoop:
    push cx
    ; di = cx*320, point to the correct screen line
    mov di,cx
    shl cx,6
    shl di,8
    add di,cx
    ; Read one line
    mov ah,3fh
    mov cx,320
    mov dx,offset ScrLine
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,320
    mov si,offset ScrLine
    rep movsb ; Copy line to the screen
    ;rep movsb is same as the following code :
    ;mov es:di, ds:si
    ;inc si
    ;inc di
    ;dec cx
    ;loop until cx=0
    pop cx
    loop PrintBMPLoop
    ret
endp CopyBitmap
proc bagrond
    push ax
    push di
    push es
    push cx
    push dx
    push ds
    push bx
    mov cx ,0
    mov di ,0
    mov bx , offset killPlcae
    mov bx , [bx]
    mov ax,0A000h
    mov es, ax
    mov ax,bgSeg
    mov ds, ax
    mov ax , 0
    mov dx , 0
    rowes:
        inc cx
        add di, 320
        sub di , ax
        mov ax ,0
        colomes:
            inc ax
            inc di
            mov dl , [byte ptr di]
            mov [es:di] , dl
            cmp ax , bx
            jnz colomes
        cmp cx , 200
        jnz rowes
    mov di, bx; second bg
    add di , 10
    mov cx ,0
    mov ax , 0
    rowe2:
        inc cx
        add di, 320
        sub di , ax
        mov ax ,0
        colome2:
            inc ax
            inc di
            mov dl , [byte ptr di]
            mov [es:di] , dl
            cmp ax , 300
            jnz colome2
        cmp cx , 200
        jnz rowe2
    pop bx
    pop ds
    pop dx
    pop cx
    pop es
    pop di
    pop ax
    ret
endp bagrond
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
        cmp cx , 200
        jnz rowe
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
    push ax
    mov bx , offset killplcae
    mov ax , 325
    mov [bx], ax 
    mov bx , offset sizeoffkiller
    mov al , [byte ptr bx]
    cmp al, 40
    jle lower
    mov ax , 50
    sub [bx], ax
    jmp d
    lower: 
    mov al , 120
    mov [byte ptr bx] , al
    d:
    pop ax
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
        cmp si, [offset bise] 
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
    mov ax , 140 
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
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap
    mov ax, 0A000h 
    mov es, ax
inf:
    call discigoin
    call readNN
    call move
    call drowkiller
    call bagrond
    call drowPlayer
    call waite
    jmp inf

exit:
    mov ax, 4c00h
    int 21h
END start
