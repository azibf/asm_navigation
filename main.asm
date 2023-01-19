
ORG  0x100
BITS 16

%include "stdlib.mac"

%macro SOLVE 0

    CALL _solve

%endmacro

%macro STR2FLT 1
    PUSH %1
    CALL _str2flt
    ADD SP, 2

%endmacro

%macro FARCCOS 0

    CALL _farccos

%endmacro

%macro FARCSIN 0

    CALL _farcsin

%endmacro

section .text

start:

	CLRSCR
	PUTS     splashscreen

	PUTS     prompt_1

	READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[h1], DWORD[outb]

    READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[h2], DWORD[outb]

    READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[d1], DWORD[outb]

    READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[d2], DWORD[outb]

    READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[t_g1], DWORD[outb]

    READLINE in_buffer, 1
    STR2FLT in_buffer
    MOV DWORD[t_g2], DWORD[outb]

	CLI
	HLT

; bool _solve(unsigned short x);
_solve:
    FINIT
    ;D12
    FLD WORD [t_g1]
    FLD WORD [t_g2]
    FSUBP
    FST WORD [d_t]
    FCOS
    FLD WORD [d1]
    FSINCOS
    FLD WORD [d2]
    FSINCOS ; COS(D2) SIN(D2) COS(D1) SIN(D1) COS(D_T)
    FMULP st2, st0 ; SIN(D2) COS(D1)*COS(D2) SIN(D1) COS(D_T)
    FMULP st2, st0 ; COS(D1)*COS(D2) SIN(D1)*SIN(D2) COS(D_T)
    FMULP st2, st0 ; SIN(D1)*SIN(D2) COS(D_T)*COS(D1)*COS(D2)
    FADDP
    FARCCOS
    FST WORD [D12]
    ;q1
    FPTAN
    FLD WORD [d1]
    FPTAN
    FDIVP st0, st1
    FLD WORD [D12]
    FSIN
    FLD WORD [d1]
    FCOS
    FMULP
    FLD WORD [d2]
    FSIN
    FDIVP st0, st1
    FSUBP
    FARCCOS
    FSTP WORD [q1]
    ;dq1
    FLD WORD [D12]
    FPTAN
    FLD WORD [h1]
    FPTAN
    FDIVP st0, st1
    FLD WORD [D12]
    FSIN
    FLD WORD [h1]
    FCOS
    FMULP
    FLD WORD [h2]
    FSIN
    FDIVP st0, st1
    FSUBP
    FARCCOS
    FST WORD [dq1]
    ;f
    FLD WORD [q1]
    FADDP
    FCOS
    FLD WORD [h1]
    FSINCOS
    FLD WORD [d1]
    FSINCOS ; COS(D1) SIN(D1) COS(H1) SIN(H1) COS(DDQ)
    FMULP st2, st0 ;  SIN(D1) COS(H1)*COS(D1) SIN(H1) COS(DDQ)
    FMULP st2, st0 ;  COS(H1)*COS(D1) SIN(H1)*SIN(D1) COS(DDQ)
    FMULP st2, st0 ;  SIN(H1)*SIN(D1) COS(DDQ)*COS(H1)*COS(D1)
    FADDP
    FARCSIN
    FST WORD [f]
    FPTAN
    FLD WORD [d1]
    FPTAN
    FLD WORD [f]
    FCOS
    FLD WORD [d1]
    FCOS
    FMULP
    FLD WORD [h1]
    FSIN
    FDIVP st0, st1
    FSUBP
    FST WORD [t1]
    FST WORD [t_m11]
    FLDPI
    FSUBP
    FST WORD [t_m12]
    FLD WORD [t_g1]
    FSUBP st1 - st0
    FLD WORD [t_g2]
    FADDP
    FLD WORD [t_g1]
    FLD WORD [t_m11]
    FSUBP st0, st1
    FADDP
    ;T_M21, T_M22
    FXCH
    FCOS
    FLD WORD [d2]
    FSINCOS
    FLD WORD [f]
    FSINCOS
    FMULP st2, st0
    FMULP st2, st0
    FMULP st2, st0
    FADDP
    FARCSIN
    FLD WORD [h2]
    FSUBP
    FABS

    FXCH
    FCOS
    FLD WORD [d2]
    FSINCOS
    FLD WORD [f]
    FSINCOS
    FMULP st2, st0
    FMULP st2, st0
    FMULP st2, st0
    FADDP
    FARCSIN
    FLD WORD [h2]
    FSUBP
    FABS
    FWAIT
    FCOMP
    FTST
    FSTSW AX
    SAHF
    JA _load_t_m12
    FLD WORD [t_m11]
    JMP _end
    _load_t_m12:
    FLD WORD [t_m12]
    _end:
    FLD WORD [t_g1]
    FSUBP st1, st0
    FSTP WORD [u]
    RET

_farccos:
    FLD st0
    FLD st0
    FMULP
    FLD1
    FSUBP st0, st1
    FSQRT
    FDIVP st0, st1
    FPATAN
    RET

_farcsin:
    FLD st0
    FLD st0
    FMULP
    FLD1
    FSUBP st0, st1
    FSQRT
    FDIVP st1, st0
    FPATAN
    RET

_str2flt:
    PUSH BP
    MOV BP, SP
    SUB SP, 2

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV WORD [BP-2], 0

    XOR CX, CX
    MOV BX, WORD [BP+4]

    CMP BYTE [BX], '-'
    JNE .pass_neg_flag
    MOV WORD [BP-2], 1
    INC BX

.pass_neg_flag:
	MOV DWORD[u_n], 10
	FILD DWORD[u_n]
	FLDZ

.before_period:
	MOV AL, BYTE[BX]
	CMP AL, 0x2E
	JE .is_point
	CMP AL, 0x00
	JE .end_as_int

	SUB AL, 30h
	MOV BYTE[u_n], AL
	FIADD DWORD[u_n]
	FMUL st0, st1

	INC BX
	JMP .before_period

.is_point:
	INC BX
	FDIV st0, st1
	FXCH st1

	MOV AL, 0x00
.find_next:
	CMP BYTE[BX], 0x00
	JE .find_end
	INC BX
	INC CX
	JMP .find_next
.find_end:
	DEC BX
	FLDZ
.after_period:
	MOV AX, WORD[BX]
	CMP AL, 0x2E
	JE .point_after

	SUB AL, 30h
	MOV BYTE[u_n], AL

	FIADD DWORD[u_n]
	FDIV st0, st1
	DEC BX
	LOOP .after_period
.point_after:
	FXCH st1
	FXCH st2
	FADDP st1
	FXCH st1
	FISTP DWORD[u_n]
	JMP .end
.end:
	FSTP DWORD[outb]  ;сохраняет float в память которая указана тут
	POP DX
	POP CX
	POP BX
	POP AX

	ADD SP ,2
	MOV SP, BP
	POP BP
	RET
.end_as_int:


%include "stdlib.asm"

section .data

splashscreen:
	DB "Etude assembly from hellbook02 by azibf and honz0", 0x0D, 0x0A
	DB "Jack Sparrow", 0x0D, 0x0A
	DB "--------------------------------------", 0x0D, 0x0A
	DB "Marine navigation software"
	DB 0x0D, 0x0A, 0x0D, 0x0A
	DB "Tap any key to start", 0

prompt_1:
    DB "Enter h1, h2, d1, d2, t_g1, t_g2  "

mod_letter:
    DB "Start: ", 0x0D, 0x0A, 0

done:
	DB "DONE", 0x0D, 0x0A, 0

h1:
    DW 0
    DW 0

h2:
    DW 0
    DW 0

t_g1:
    DW 0
    DW 0

t_g2:
    DW 0
    DW 0

d1:
    DW 0
    DW 0

d2:
    DW 0
    DW 0

d_t:
    DW 0
    DW 0

D12:
    DW 0
    DW 0

q1:
    DW 0
    DW 0

dq1:
    DW 0
    DW 0

f:
    DW 0
    DW 0

t1:
    DW 0
    DW 0

t_m11:
    DW 0
    DW 0

t_m12:
    DW 0
    DW 0

t_m21:
    DW 0
    DW 0

t_m22:
    DW 0
    DW 0

u:
    DW 0
    DW 0

space:
	DB " ", 0

my_buffer:
	RESB 256

in_buffer:
	RESB 256
u_n:
	dw 1
outa:
	resb 256
outb:
	resb 256
