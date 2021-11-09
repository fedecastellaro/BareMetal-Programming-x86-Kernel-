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
    ;load gdt con lo que tiene en memoria [] en _gdtr
    ;con esto cargamos la gdt pero no entramos en modo protegido
    ;el ds arranca con la base en cero, por lo que el gdtr va a tener que apuntar al shadow

    ; -------------- Configuro PIC ----------------
    jmp InitPIC
    Return_ReprogramarPICs:
    push bp
    mov bp, sp
    call VGA_Init
    leave
    xchg    bx,bx

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


%define PIC1_COMMAND	0x20
%define PIC1_DATA	0x21
%define PIC2_COMMAND	0xA0
%define PIC2_DATA	0xA1

InitPIC:
	;Inicialización de ambos PICs mediante ICW (Initialization Control Words)
	
        ;ICW1 = Indicarle a los PIC que estamos inicializándolo.
        mov	al,0x11        	    ;Palabra de inicialización (bit 4=1) indicando que se necesita ICW4 (bit 0=1)
        out PIC1_COMMAND,al   	;Enviar ICW1 al primer PIC
        out PIC2_COMMAND,al		;Enviar ICW1 al segundo PIC

        ;ICW2 = Indicarle a los PIC cuales son los vectores de interrupciones
        mov al,0x20        	    ;El primer PIC va a usar los tipos de interr 0x20-0x27
        out PIC1_DATA,al 		;Enviar ICW2 al primer PIC
        mov al,0x28 		    ;El segundo PIC va a usar los tipos de interr 0x28-0x2F 			
        out PIC2_DATA,al 		;Enviar ICW2 al segundo PIC

        ;ICW3 = Indicarle a los PIC como se conectan como master y slave
        mov al,0x04         ;Decirle al primer PIC que hay un PIC esclavo en IRQ2
        out PIC1_DATA,al	;Enviar ICW3 al primer PIC
        mov al,0x02 		;Decirle al segundo PIC su ID de cascada (2)
        out PIC2_DATA,al 	;Enviar ICW3 al segundo PIC

        ;ICW4 = Información adicional sobre el entorno
        mov al,0x01         ;Poner el PIC en modo 8086
        out PIC1_DATA,al 	;Enviar ICW4 al primer PIC
        out PIC2_DATA,al 	;Enviar ICW4 al segundo PIC

        ; HABILITACION DE INTERRUPCIONES EXTERNAS:
        ; PARA ESTE CASO, TODAS DESHABILITADAS
        ; ( 1 -> DESHABILITADA)
        ; ( 0 -> HABILITADA)
        mov al,11111100b     	;Deshabilito todos los IRQ poniendo bits a 1
        out PIC1_DATA,al    ;Enviar máscara al primer PIC	
        STI
        
        jmp Return_ReprogramarPICs