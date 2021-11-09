;--------------------------------------------------------------------------------
; Simbolos externos
;--------------------------------------------------------------------------------
GLOBAL		start32

GLOBAL isr0_handler
GLOBAL isr0_handler_DE
GLOBAL isr2_handler_NMI
GLOBAL isr3_handler_BP
GLOBAL isr4_handler_OF
GLOBAL isr5_handler_BR
GLOBAL isr6_handler_UD
GLOBAL isr7_handler_NM
GLOBAL isr8_handler_DF
GLOBAL isr10_handler_TS
GLOBAL isr11_handler_NP
GLOBAL isr12_handler_SS
GLOBAL isr13_handler_GP
GLOBAL isr14_handler_PF
GLOBAL isr16_handler_MF
GLOBAL isr17_handler_AC
GLOBAL isr18_handler_MC
GLOBAL isr19_handler_XF
GLOBAL isr20_handler_VE
GLOBAL isr32_255_handler

EXTERN CS_SEL_32
EXTERN NO_SEL_32


;--------------------------------------------------------------------------------
; Macros
;--------------------------------------------------------------------------------

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60
%define 	TABLA_DIG 		0x00210000

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60
%define 	TECLA_Y			0x15
%define 	TECLA_U			0x16
%define 	TECLA_I			0x17
%define 	TECLA_O			0x18
%define 	TECLA_F			0x21



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
	;xchg bx,bx					;Magic breakpoint
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
	;xchg bx,bx	 				;Magic breakpoint		
	
	Y:							;Y = #DE (Interrupt 0—Divide Error Exception)
		cmp al,TECLA_Y 			;Comparo para saber si se presiona la tecla Y
		jne U 					;Salto a U si no se presiono la tecla Y
		mov edx, 0        		;Genero el error de división 
		mov eax, 0x02			;Divido edx:eax/esi
		mov esi, 0
		div esi
		hlt

	U: 							;U = #UD (Interrupt 6—Invalid Opcode Exception)
		cmp al,TECLA_U 			;Comparo para saber si se presiona la tecla U
		jne I 					;Salto a I si no se presiono la tecla U
		dw  0xFFFF        		;Genero un opcode invalido
		hlt

	I: 							;I = #DF (Interrupt 8—Double Fault Exception)
		cmp al,TECLA_I 			;Comparo para saber si se presiona la tecla I
		jne O 					;Salto a O si no se presiono la tecla I
		mov ax,NO_SEL_32		;Cargo un segmento no presente para generar un #SS
		mov ss,ax
		hlt

	O: 							;O = #GP (Interrupt 13—General Protection Exception)
		cmp al,TECLA_O 			;Comparo para saber si se presiona la tecla O
		jne F 					;Salto a F si no se presiono la tecla O
		mov ax,0				;Trato de cargar un segmento inexistente
		mov ss,ax
		hlt

	F: 							;F = Fin del programa
		cmp al,TECLA_F 			;Comparo para saber si se presiona la tecla F 
		jne Polling 			;Si no es la tecla F salto a Polling
		jmp Colgarse 			;Si es la tecla F salto a Colgarse	
	

;ISR

default_isr:
   	nop
   	hlt

isr0_handler_DE: 		;Interrupt 0—Divide Error Exception (#DE)
   	mov dx,0
   	jmp default_isr
   						
;isr1_handler_DE: 		;Interrupt 1—Debug Exception (#DB)
;    mov dx,1
;    jmp default_isr

isr2_handler_NMI: 		;Interrupt 2—NMI Interrupt
    mov dx,2
    jmp default_isr

isr3_handler_BP: 		;Interrupt 3—Breakpoint Exception (#BP)
    mov dx,3
    jmp default_isr

isr4_handler_OF: 		;Interrupt 4—Overflow Exception (#OF)
    mov dx,4
    jmp default_isr

isr5_handler_BR: 		;Interrupt 5—BOUND Range Exceeded Exception (#BR)
    mov dx,5
    jmp default_isr

isr6_handler_UD: 		;Interrupt 6—Invalid Opcode Exception (#UD)
    mov dx,6
	xchg bx,bx
    jmp default_isr

isr7_handler_NM: 		;Interrupt 7—Device Not Available Exception (#NM)
    mov dx,7
    jmp default_isr

isr8_handler_DF: 		;Interrupt 8—Double Fault Exception (#DF)
    mov dx,8
    jmp default_isr

isr10_handler_TS: 		;Interrupt 10—Invalid TSS Exception (#TS)
    mov dx,10
    jmp default_isr

isr11_handler_NP: 		;Interrupt 11—Segment Not Present (#NP)
    mov dx,11
    jmp default_isr

isr12_handler_SS: 		;Interrupt 12—Stack Fault Exception (#SS)
    mov dx,12
    jmp default_isr

isr13_handler_GP:  		;Interrupt 13—General Protection Exception (#GP)
    mov dx,13
    jmp default_isr

isr14_handler_PF:  		;Interrupt 14—Page-Fault Exception (#PF)
    mov dx,14
    jmp default_isr

isr16_handler_MF:  		;Interrupt 16—x87 FPU Floating-Point Error (#MF)
	xchg bx, bx
    mov dx,16
    jmp default_isr

isr17_handler_AC: 		;Interrupt 17—Alignment Check Exception (#AC)
    mov dx,17
    jmp default_isr

isr18_handler_MC: 		;Interrupt 18—Machine-Check Exception (#MC)
    mov dx,18
    jmp default_isr

isr19_handler_XF: 		;Interrupt 19—SIMD Floating-Point Exception (#XM)
    mov dx,19
    jmp default_isr

isr20_handler_VE: 		;Interrupt 20—Virtualization Exception (#VE)
    mov dx,20
    jmp default_isr

isr32_255_handler: 		;Interrupts 32 to 255—User Defined Interrupts
    mov dx,32
    jmp default_isr