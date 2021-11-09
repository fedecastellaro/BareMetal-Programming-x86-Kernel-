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

EXTERN      __TABLE_INIT
EXTERN      __printf_sum
EXTERN      __my_printf

EXTERN      __TABLE_INIT
EXTERN      _acumular_en_tabla_aux
EXTERN      _acumular_en_tabla_fin
EXTERN      _acumular_en_buffer

EXTERN      __VARIABLES
USE32


;********************************************************************************
; Datos
;********************************************************************************
SECTION 	.datos		

flag  dd 0
msg:  DB 'Ej 1.9 - Al presionar ENTER se muestra en pantalla la suma de los numeros',0
largo EQU $ - msg
;********************************************************************************
; Nucleo
;********************************************************************************
SECTION     .nucleo

start32:
    call init_entrada_teclado

    ;Muestro presentación del ejercicio en pantalla
    push ebp
    mov ebp, esp
    push largo
    push msg
    call __my_printf
    leave

	jmp  Colgarse 		 		;Me cuelgo, esperando las interrupciones del teclado

Colgarse:

	hlt 						;Establezco el procesador en estado halted
	jmp Colgarse 				;Salto a Colgarse

init_entrada_teclado:
    mov esi,__TABLE_INIT        	;Cargo el inicio de la tabla 
	xor edi,edi                	    ;Limpio el offset
    ; ya tengo mi puntero al inico de la tabla
    ; Limpio los 16 bytes de la posicion 0x00210000
    mov ecx, 0xF ;Tamaño del Buffer
    add esi, ecx
    .blanqueo:
        dec esi
        mov byte [esi], 0x00 
    loop .blanqueo
    ret



