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

EXTERN      __printf_sum
EXTERN      __my_printf

EXTERN      __TABLE_INIT_VMA
EXTERN      _acumular_en_tabla_aux
EXTERN      _acumular_en_tabla_fin
EXTERN      _acumular_en_buffer

EXTERN      __DATOS_FIS
USE32


;********************************************************************************
; Datos
;********************************************************************************
SECTION 	.datos		

flag    dd  0
indice  dd  0

msg:  DB 'Ej 1.11 - Al presionar ENTER se muestra en pantalla la suma de los numeros',0
largo EQU $ - msg

msg2: db 'Esta vez distribuyendo la memoria mediante paginacion',0
largo2 EQU $ - msg2

msg3: db 'Suma total de los numeros(ingresados en el orden correcto):',0
largo3 EQU $ - msg3

%define FILA_0  0
%define FILA_1  1
%define FILA_2  2
%define FILA_3  3
%define COLUMNA_0   0


;********************************************************************************
; Nucleo
;********************************************************************************
SECTION     .nucleo

start32:
    ;Muestro presentación del ejercicio en pantalla
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
    push FILA_3
    call __my_printf
    leave

	jmp  Colgarse 		 		;Me cuelgo, esperando las interrupciones del teclado


Colgarse:
	hlt 						;Establezco el procesador en estado halted
	jmp Colgarse 				;Salto a Colgarse


