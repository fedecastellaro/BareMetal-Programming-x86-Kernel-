%include "inc/procesor-flags.h"

%define     PORT_A_8042    0x60        ;Puerto A de E/S del 8042
%define     CTRL_PORT_8042 0x64        ;Puerto de Estado del 8042
%define     KEYB_DIS       0xAD        ;Deshabilita teclado con Command Byte
%define     KEYB_EN        0xAE        ;Habilita teclado con Command Byte
%define     READ_OUT_8042  0xD0        ;Copia en 0x60 el estado de OUT
%define     WRITE_OUT_8042 0xD1        ;Escribe en OUT lo almacenado en 0x60

USE16
section .ROM_init

EXTERN  __STACK_START_16
EXTERN  __STACK_END_16
EXTERN  CS_SEL_16
EXTERN  _gdtr16
EXTERN  _idtr
EXTERN  start32_launcher
EXTERN  halted
EXTERN  VGA_Init

GLOBAL start16

start16:
    test  eax, 0x0 ; con estas dos lineas se verifica que el uP no esté en fallo
    jne   halted   ; jne = jump not equal

    jmp   A20_Enable_No_Stack ; salta a la rutina de activacion de gateA20
                            ; como estoy en ROM, todavia no tengo stack y por ende no puedo hacer CALL
A20_Enable_No_Stack_return:

    xor eax, eax
    mov cr3, eax  ; invalido TLB = Translation Lookaside Buffer
                    ;Habilitar Stack 16 bits
    mov ax, cs ;  recordar que cs = 0xfffffff0. Los primeros 4 f son ocultos!
    mov ds, ax ; Este mov no copia la parte oculta de cs!       
    mov ax, __STACK_START_16
    mov ss, ax
    mov ax, __STACK_END_16
    mov sp, ax

                    ;Deshabilitar Cache
    mov eax, cr0
    or  eax, (X86_CR0_NW | X86_CR0_CD)
    mov cr0, eax
    wbinvd                  ;write back and invalidates cache

    o32 lgdt    [_gdtr16]     ;utiliza implícitamente [ds] -> [ds:_gdtr]

    ; -------------- Configuro PIC ----------------
    push bp
    mov  bp, sp
    call VGA_Init
    leave

                    ;Modo protegido
    smsw    ax
    or      ax, X86_CR0_PE
    lmsw    ax
    
    o32 jmp     dword CS_SEL_16:start32_launcher

    jmp halted


A20_Enable_No_Stack:
        xor ax, ax
        mov di, .8042_kbrd_dis
        jmp .empty_8042_in
.8042_kbrd_dis:
        mov al, KEYB_DIS
        out CTRL_PORT_8042, al
        mov di, .8042_read_out
        jmp .empty_8042_in
        .8042_read_out:
        mov al, READ_OUT_8042
        out CTRL_PORT_8042, al
.empty_8042_out:  
        xor bx, bx   
        in al, PORT_A_8042
        mov bx, ax
        mov di, .8042_write_out
        jmp .empty_8042_in
.8042_write_out:
        mov al, WRITE_OUT_8042
        out CTRL_PORT_8042, al
        mov di, .8042_set_a20
        jmp .empty_8042_in
.8042_set_a20:
        mov ax, bx
        or ax, 00000010b
        out PORT_A_8042, al
        mov di, .8042_kbrd_en
        jmp .empty_8042_in
.8042_kbrd_en:
        mov al, KEYB_EN
        out CTRL_PORT_8042, al
        mov di, .a20_enable_no_stack_exit
.empty_8042_in:  
        jmp di
.a20_enable_no_stack_exit:
        jmp A20_Enable_No_Stack_return

endcode:
