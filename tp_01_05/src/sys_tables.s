SECTION .sys_tables
EXTERN  EXCEPTION_DUMMY
GLOBAL  CS_SEL_16
GLOBAL  CS_SEL_32
GLOBAL  DS_SEL
GLOBAL  _gdtr

%define BOOT_SEG 0XF0000

GDT:
NULL_SEL    equ $-GDT
    dq  0x0
CS_SEL_16   equ $-GDT
    dw  0xffff      ;Limit  15-0
    dw  0x0000      ;Base 15-0
    db  0xff        ;Base 23-16
    db  10011001b   ;Atributos:
                    ;P = 1
                    ;DPL = 00
                    ;S = 1
                    ;D/C = 1
                    ;ED/C = 0
                    ;R/W = 0
                    ;A = 1
    db  01000000b   ;Atributos + Limit 19-16
                    ;G = 0
                    ;D/B = 1
                    ;L =0
                    ;AVL = 0
    db  0xff        ;Base 31-24
CS_SEL_32   equ $-GDT
    dw  0xffff      ;Limit  15-0
    dw  0x0000      ;Base 15-0
    db  0x00        ;Base 23-16
    db  10011001b   ;Atributos
                    ;P = 1
                    ;DPL = 00
                    ;S = 1
                    ;D/C = 1
                    ;ED/C = 0
                    ;R/W = 0
                    ;A = 1
    db  11001111b   ;Limit 19-16
                    ;G = 1
                    ;D/B = 1
                    ;L = 0
                    ;AVL = 0
    db 0x00         ;Base 31-24
DS_SEL      equ $-GDT
    dw 0xffff       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 10010010b    ;Atributos
                    ;P = 1
                    ;DPL = 00
                    ;S = 1
                    ;D/C = 0
                    ;ED/C = 0
                    ;R/W = 1
                    ;A = 0
    db 11001111b    ;Atributos + Limit 19-16:
                    ;G = 1
                    ;D/B = 1
                    ;L = 0
                    ;AVL = 0
    db 0x00         ;Base 31-24
GDT_LENGTH  equ $-GDT

_gdtr:
    dw  GDT_LENGTH -1
    dd  0x000ffd00