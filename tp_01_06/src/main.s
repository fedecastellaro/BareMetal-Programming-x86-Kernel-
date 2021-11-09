;--------------------------------------------------------------------------------
; Simbolos externos
;--------------------------------------------------------------------------------
GLOBAL		start32


;--------------------------------------------------------------------------------
; Macros
;--------------------------------------------------------------------------------

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60
%define 	TECLA_F			0x21
%define 	TABLA_DIG 		0x00210000



;********************************************************************************
; Datos
;********************************************************************************
SECTION 	.datos		
msgInicio 	db "TD3 - TP1 - Ejercicio 6 .....", 0
msgInicio2	db "Castellaro, Federico: fedecastellaro9@gmail.com",0
;********************************************************************************
; Nucleo
;********************************************************************************
USE32
SECTION     .nucleo

start32:
	xchg bx,bx					;Magic breakpoint
	jmp RutinaTeclado 			;Salto a RutinaTeclado

Colgarse:
	hlt 						;Establezco el procesador en estado halted
	jmp Colgarse 				;Salto a Colgarse


;********************************************************************************
; Rutina Teclado
;********************************************************************************

SECTION 	.rutina_teclado

RutinaTeclado:

	mov esi,TABLA_DIG        	;Cargo el inicio de la tabla 
	xor edi,edi                	;Limpio el offset

Polling:
	;Consulto el estado del teclado
	xor eax,eax               	;Limpio el registro eax
	in al,0x64            	    ;Consulto el estado del teclado para ver si hubo actividad
	bt eax,0x00               	;Si hay un 1 en el bit 0 significa que hubo actividad
	jnc Polling 				;Si no hay un 1 en el bit 0 no hubo actividad y salto a Polling

	;Analizo si quiero actuar cuando se presiona o cuando se suelta la tecla
	in al,0x60					;Leo tecla del buffer de teclado
	bt eax,0x07               	;Si hay un 1 en el bit 7 significa que fue de soltar
	jc Polling 					;Salto a Polling si hay carry 

TablaDigitos:
	;Guardo en la tabla
	mov [esi+edi],al 			;Muevo el valor al puntero correspondiente
	inc di  					;di tiene 16 bits -> el limite de offset es 64kB
	
	;jne TablaDigitos  			;Para probar que llena los 64kB
	
	cmp al,TECLA_F 				;Comparo para saber si se presiona la tecla F 
	jne Polling 				;Si no es la tecla F salto a Polling
	jmp Colgarse 				;Si es la tecla F salto a Colgarse