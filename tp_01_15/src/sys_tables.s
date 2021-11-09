
EXTERN  EXCEPTION_DUMMY
GLOBAL  CS_SEL_16
GLOBAL  CS_SEL_KERNEL
GLOBAL  DS_SEL_KERNEL
GLOBAL  CS_SEL_USER
GLOBAL  DS_SEL_USER

GLOBAL  DS_SEL
GLOBAL  D_TSS
GLOBAL  _gdtr
GLOBAL	_gdtr16
GLOBAL  _idtr

EXTERN isr0_handler_DE
EXTERN isr2_handler_NMI
EXTERN isr3_handler_BP
EXTERN isr4_handler_OF
EXTERN isr5_handler_BR
EXTERN isr6_handler_UD
EXTERN isr7_handler_NM
EXTERN isr8_handler_DF
EXTERN isr10_handler_TS
EXTERN isr11_handler_NP
EXTERN isr12_handler_SS
EXTERN isr13_handler_GP
EXTERN isr14_handler_PF
EXTERN isr16_handler_MF
EXTERN isr17_handler_AC
EXTERN isr18_handler_MC
EXTERN isr19_handler_XF
EXTERN isr20_handler_VE
EXTERN isr32_255_handler
EXTERN isr_tick
EXTERN isr_teclado
EXTERN isr_int_0x80


;********************************************************************************
; Tablas de sistema
;********************************************************************************

;--------------------------------------------------------------------------------
; GDT provisoria para inicio en 16 bits. Queda dentro de la ROM
;--------------------------------------------------------------------------------

SECTION .sys_table_gdt16

GDT16:
	NULL_SEL_16	EQU		$-GDT16
		dq		0x0

	CS_SEL_16   EQU 	$-GDT16
		dw 		0xFFFF 
		dw 		0x0000
		db 		0x00
		db 		0x9A ; Atributos : 10011010 -> DPL = 00  	
		db 		0xCF
		db 		0
			
	DS_SEL_16  	EQU 	$-GDT16
		dw 		0xFFFF 
		dw 		0x0000
		db 		0x00
		db 		0x92
		db 		0xCF
		db 		0

	GDT16_LENGTH EQU 	$-GDT16

_gdtr16:
	dw 		GDT16_LENGTH-1
	dd 		GDT16


SECTION		.sys_table_gdt

;--------------------------------------------------------------------------------
; GDT
;--------------------------------------------------------------------------------
GDT:
	NULL_SEL            equ $-GDT
	dq 0x0

	CS_SEL_KERNEL       equ $-GDT
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 0x98
	db 0xCF
	db 0x00

	DS_SEL_KERNEL       equ $-GDT
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 0x92
	db 0xCF
	db 0x00

	CS_SEL_USER         equ $-GDT+3
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 0xF8
	db 0xCF
	db 0x00

	DS_SEL_USER         equ $-GDT+3
	dw 0xFFFF
	dw 0x0000
	db 0x00
	db 0xF2
	db 0xCF
	db 0x00
	
	D_TSS               equ $-GDT       ; direccion TSS: 0x0050 0000
	dw 0x0068
	dw 0x0000
	db 0x50
	db 0x89
	db 0x00
	db 0x00

	GDT_LENGTH          equ $-GDT

_gdtr:
	dw 		GDT_LENGTH-1
	dd 		GDT	
	

;--------------------------------------------------------------------------------
; IDT
;--------------------------------------------------------------------------------
SECTION .sys_table_idt
IDT:
	ISR0_DE:                     ; Define 0
		dw isr0_handler_DE
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR1:                     ; Define 8
		dq 0x0

	ISR2_NMI:
		dw isr2_handler_NMI
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR3_BP:
		dw isr3_handler_BP
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR4_OF:
		dw isr4_handler_OF
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR5_BR:
		dw isr5_handler_BR
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR6_UD:
		dw isr6_handler_UD
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR7_NM:
		dw isr7_handler_NM
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR8_DF:
		dw isr8_handler_DF
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR9:
		dq 0x0

	ISR10_TS:
		dw isr10_handler_TS
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR11_NP:
		dw isr11_handler_NP
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR12_SS:
		dw isr12_handler_SS
		dw CS_SEL_KERNEL 			
		db 0x00
		db 0x8F
		dw 0x00

	ISR13_GP:
		dw isr13_handler_GP
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR14_PF:
		dw isr14_handler_PF
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR15:
		dq 0x0

	ISR16_MF:
		dw isr16_handler_MF
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR17_AC:
		dw isr17_handler_AC
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR18_MC:
		dw isr18_handler_MC 
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR19_XF:
		dw isr19_handler_XF
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8F
		dw 0x00

	ISR20_31:        ; Reservado
		times 12 dq 0x0
	
	ISR_32:
		dw isr_tick 	;Offset 15-0
		dw CS_SEL_KERNEL	;Selector
		db 0x00			;No usado
		db 0x8E			;Compuerta de interrupcion
		dw 0x00			;Offset 31-16

	ISR_33:
		dw isr_teclado
		dw CS_SEL_KERNEL
		db 0x00
		db 0x8E
		dw 0x00		

	ISR34_127:        
		times 94 dq 0x0
	
	ISR_128:	 			;isr_int_0x80         128
		dw isr_int_0x80
		dw (CS_SEL_KERNEL + 3)          ; cs nivel 0 con rpl nivel 3
		db 0x00
		db 0xEE
		dw 0x0000
		
IDT_LENGTH  EQU 	$-IDT

_idtr:
	dw 		IDT_LENGTH-1
	dd 		IDT
