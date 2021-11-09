; https://stackoverflow.com/questions/1856320/purpose-of-esi-edi-registers
; https://www.tutorialspoint.com/assembly_programming/assembly_registers.htm
; http://www.eecg.toronto.edu/~amza/www.mindsec.com/files/x86regs.html
; http://www.unixwiz.net/techtips/x86-jumps.html
; https://wiki.osdev.org/PS/2_Keyboard

;--------------------------------------------------------------------------------
; Simbolos externos
;--------------------------------------------------------------------------------
GLOBAL		start32
GLOBAL      main
GLOBAL      indice
GLOBAL      msg3


GLOBAL 	Cant_digitos_tabla
GLOBAL 	CantDigitos
GLOBAL 	TareaActual
GLOBAL 	ContTarea1
GLOBAL 	ContTarea2
GLOBAL  cantidad_de_pag_added
GLOBAL  flag_task0_off
GLOBAL  indice_final
;--------------------------------------------------------------------------------
; Macros
;--------------------------------------------------------------------------------

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60
%define 	TECLA_Y			0x15
%define 	TECLA_U			0x16
%define 	TECLA_I			0x17
%define 	TECLA_O			0x18
%define 	TECLA_F			0x21
%define     FILA_0          0
%define     FILA_1          1
%define     FILA_2          2
%define     FILA_4          4
%define     FILA_9          9
%define     FILA_10         10

%define     COLUMNA_0       0

EXTERN      __my_printf

EXTERN      __TASK0_DIR_PAG_START
EXTERN      __TASK1_DIR_PAG_START
EXTERN      __TASK2_DIR_PAG_START
EXTERN      Idle_Task_0
EXTERN      task1
EXTERN      task2
EXTERN      largo4
EXTERN      msg4
EXTERN      largo5
EXTERN      msg5

EXTERN      __STACK_END_TAREA_VMA
EXTERN      DS_SEL_KERNEL
EXTERN      CS_SEL_KERNEL
EXTERN      DS_SEL_USER
EXTERN      CS_SEL_USER

EXTERN      __STACK_END_TASK0_USR_VMA
EXTERN      __STACK_END_TASK1_USR_VMA
EXTERN      __STACK_END_TASK2_USR_VMA

EXTERN      __STACK_END_TASK0_SUP_VMA
EXTERN      __STACK_END_TASK1_SUP_VMA
EXTERN      __STACK_END_TASK2_SUP_VMA

USE32
;********************************************************************************
; Datos
;********************************************************************************
SECTION 	.datos		

msg:  DB 'Ej 1.13 - Al presionar ENTER se muestra en pantalla la suma de los numeros',0
largo EQU $ - msg

msg2: db 'Se estan ejecutando dos tareas, cada una mostrando la suma de los numeros de la tabla de digitos',0
largo2 EQU $ - msg2

msg3: db 'Suma total de los numeros:',0
largo3 EQU $ - msg3

ContTarea1: 	
	resb 0x2			;Reservo 2 byte

ContTarea2: 	
	resb 0x2			;Reservo 2 byte

Cant_digitos_tabla:
	resb 0x1 			;Reservo 1 byte

IndiceTeclaLoop:
	resb 0x1			;Reservo 1 byte

IndiceTablaDigitos:
	resb 0x1			;Reservo 1 byte

CantDigitos:
	resb 0x1 			;Reservo 1 byte

TareaActual:
	resb 0x1 			;Tarea que se esta ejecutando actualmente

cantidad_de_pag_added:
    resb 0x1

flag_task0_off:
    resb 0x1

indice  dd  0
indice_final dd 0

;********************************************************************************
; Nucleo
;********************************************************************************
SECTION     .nucleo

start32:
; ----------------Muestro presentación del ejercicio en pantalla-----------------;

    push ebp
    mov  ebp, esp
    push largo
    push msg
    push COLUMNA_0
    push FILA_0
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo2
    push msg2
    push COLUMNA_0
    push FILA_1
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo3
    push msg3
    push COLUMNA_0
    push FILA_4
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo4
    push msg4
    push COLUMNA_0
    push FILA_9
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo5
    push msg5
    push COLUMNA_0
    push FILA_10
    call __my_printf
    leave

    xor eax,eax                 ;Limpio los registros de uso general
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    xor edi,edi
    xor esi,esi

    mov BYTE [TareaActual],0    ; TareaActual=0

    sti                         ;Habilito interrupciones

    jmp Idle_Task_0            ;Salto a Idle_Tarea_0