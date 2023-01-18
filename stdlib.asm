; void clrscr();
_clrscr:
    PUSH BP
    MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
        
    XOR AX, AX
    MOV AH, 0x00 
    MOV AL, 0x02  ; text mode 80x25 16 color CGA
    INT 0x10   

    POP DX
    POP CX
    POP BX
    POP AX
    MOV SP, BP
    POP BP
    RET

; void putchar(char b);
_putchar:
    PUSH BP
    MOV BP, SP
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV DX, WORD [BP+4]
    XOR DH, DH

    MOV AH, 0x0E
    MOV AL, DL
    INT 0x10

    POP DX
    POP CX
    POP BX
    POP AX
    MOV SP, BP
    POP BP
    RET

; char _getchar();
_getchar:
    PUSH BP
    MOV BP, SP

    PUSH BX
    PUSH CX
    PUSH DX

    XOR AX, AX
    INT 0x16   ; AH = scancode
               ; AL = char
    POP DX
    POP CX
    POP BX

    MOV SP, BP
    POP BP
    RET


; void _puts(char* str);
_puts:
    PUSH BP
    MOV BP, SP
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, [BP+4]
    JMP .loop_entry

.app_ch:
    INC BX
    MOV AH, 0
    PUSH AX
    CALL _putchar
    ADD SP, 2

.loop_entry: 
    MOV AL, BYTE [BX]
    CMP AL, 0
    JNE .app_ch

    POP DX
    POP CX
    POP BX
    POP AX
    
    MOV SP, BP
    POP BP
    RET


; void _readLine(char* strbuf, bool echo_enabled)
_readLine:
    PUSH BP
    MOV BP, SP

    SUB SP, 3

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, WORD [BP+6] ; strbuf

.local_loop:

    CALL _getchar
    CMP AH, 0x1C
    JE .local_exit

    MOV BYTE [BX], AL ; strbuf[n] = ..;
    INC BX

    MOV CX, WORD [BP+4] ; enable_echo
    CMP CX, 0 ; if CX==FALSE
    JE .pass_echo

    PUSH AX
    CALL _putchar
    ADD SP, 2

.pass_echo:

    JMP .local_loop
 
.local_exit:

    MOV CX, WORD [BP+4] ; enable_echo
    CMP CX, 0 ; if CX==FALSE
    JE .pass_echo2

    MOV BYTE [BP-3], 0x0D
    MOV BYTE [BP-2], 0x0A
    MOV BYTE [BP-1], 0x00

    MOV DX, BP
    SUB DX, 3

    PUSH DX
    CALL _puts
    ADD SP, 2

.pass_echo2:

    MOV BYTE [BX], 0 ; '\0'

    POP DX
    POP CX
    POP BX
    POP AX

    ADD SP, 3

    MOV SP, BP
    POP BP
    RET

; unsinged short str2num(char* str);
_str2num:
    PUSH BP
    MOV BP, SP
    SUB SP, 4

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV WORD [BP-2], 0
    MOV WORD [BP-4], 0

    XOR CX, CX
    MOV BX, WORD [BP+4]

    CMP BYTE [BX], '-'
    JNE .pass_neg_flag

    MOV WORD [BP-4], 1
    INC BX

.pass_neg_flag:

.local_loop:

    MOV AL, BYTE [BX]
    CMP AL, 0x00
    JE .local_exit

    INC BX
    INC CX
    XOR AH, AH
    PUSH AX

    JMP .local_loop

.local_exit:

    XOR AX, AX
    XOR DX, DX
    MOV DL, 10
    MOV AX, 1

.local_loop2:

    POP BX
    SUB BL, '0'

    PUSH AX
    MUL BL

    ADD WORD [BP-2], AX
    POP AX

    MUL DX
    MOV DX, 10

    LOOP .local_loop2

    POP DX
    POP CX
    POP BX
    POP AX

    MOV AX, WORD [BP-2]

    CMP WORD [BP-4], 1
    JNE .pass_neg_result

    NEG AX

.pass_neg_result:

    ADD SP, 4
    MOV SP, BP
    POP BP
    RET


_num2str:
    PUSH BP
    MOV BP, SP
    SUB SP, 2

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV WORD [BP-2], 10
    MOV AX, WORD [BP+6]
    MOV BX, WORD [BP+4]

    XOR CX, CX

.loop1:
    XOR DX, DX
    DIV WORD [BP-2]
    ADD DL, '0'
    PUSH DX
    INC CX
    CMP AX, 0
    JNE .loop1

.loop2:
    POP AX
    MOV BYTE [BX], AL
    INC BX
    LOOP .loop2    
    
    MOV BYTE [BX], 0

    POP DX
    POP CX
    POP BX
    POP AX

    ADD SP, 2
    MOV SP, BP
    POP BP
    RET