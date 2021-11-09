;Excepciones
;ISR
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
GLOBAL isr_tick
GLOBAL isr_teclado
GLOBAL fin_int

EXTERN CS_SEL_32
EXTERN NO_SEL_32

EXTERN _grabar
EXTERN _tabla_aux
EXTERN _acumular

EXTERN __DATOS_VMA
EXTERN timer_control
EXTERN task1
;Resumen de lo que hago acá:

;Tengo tres funciones en funtions.c:

;_acumular_en_buffer: Guarda todas las teclas que se presionan en __TABLE_INIT_VMA + 30

;_acumular_en_tabla_aux: Guarda todos los numeros que se presionan (y esten en el orden correcto) en una tabla de 16 bytes en __TABLE_INIT_VMA + 20

;_acumular_en_tabla_fin: Copia los ultimos 8 numeros que se presionaron (y que estan en la tabla aux) en la tabla final en __TABLE_INIT_VMA esp
;Apreto cualquier tecla, ordena y guarda los numeros si se los presiona en el orden correcto, y cuando apreto enter guarda los numeros
;en la posicion de memoria de 0x00210000, respetando el orden pedido ( MSB en cero)


USE32
SECTION .isr


isr_teclado:
	pushad

	in  al, 0x60  ; lee la tecla que se pulso
	and al, al    ; Si el bit 7 de al está encendido se activa el flag de signo!
	js fin_int	  ; terminar cuando se suelta la tecla


    cmp al, 0x1C  ; comparo con ENTER, salto a preparar la table si es igual
    je _grabar
    
; si no es el enter, puede ser un numero o una letra
    CMP AL, 0x01  ; comparo con el valor limite mas chico de los numeros ( 1 = 0x02 )
    jbe _acumular ; en caso de que no lo sea, acumulo la tecla

    cmp al, 0x0B  ; comparo con el valor máximo de los numeros ( 0x0A = 9 Y 0x0B = 0) para saber si es un numero
    JG _acumular  ;en caso de que no lo sea, acumulo la tecla

    jmp _tabla_aux 


fin_int:
	mov  al, 0x20 ; Envio la signal de END of interrupt al PIC
	out  0x20, al; 
	popad		; restauro registros de uso general
    iretd


isr_tick:
	pushad
    push ebp
    mov  ebp, esp
    call timer_control    
    leave
    jmp fin_int


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
    xchg bx,bx
    mov dx,13
    jmp default_isr

isr14_handler_PF:  		;Interrupt 14—Page-Fault Exception (#PF)
    xchg bx,bx
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