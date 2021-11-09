USE32
section .start32

EXTERN  DS_SEL
EXTERN  CS_SEL_32

EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32

EXTERN  start32
EXTERN  __NUCLEO_SIZE__
EXTERN  __NUCLEO_VMA
EXTERN  __NUCLEO_LMA

EXTERN  __fast_memcpy_rom

EXTERN  __DATOS_SIZE__
EXTERN  __DATOS_VMA
EXTERN  __DATOS_LMA

EXTERN  __TECLADO_FUNC_SIZE_
EXTERN  __TECLADO_FUNC_VMA
EXTERN  __TECLADO_FUNC_LMA

EXTERN  __SYS_SIZE__
EXTERN  __SYS_TABLES_VMA
EXTERN  __SYS_TABLES_LMA

EXTERN  _idtr
EXTERN  _gdtr


GLOBAL start32_launcher
;En este punto ya me encuentro en modo protegido!
start32_launcher:
    mov     ax, DS_SEL  ; ax tiene el valor del selector de datos, que describe toda la memoria
    mov     ds, ax
    mov     es, ax
    mov     gs, ax
    mov     fs, ax

;Inicializco la pila y cargo stack selector
    mov     ss,ax
    mov     esp, __STACK_END_32 ; recordar el esp siempre al fondo de la pila
    xor     eax, eax

; Limpio la pila, y para eso uso el contador ecx

    mov ecx, __STACK_SIZE_32 ; Cargo en el contador el tamaño del stack
    .stack_init:
        push    eax             ; "pushea" (pisa) con ceros toda la memoria que compone el stack
        loop    .stack_init     ; Recordar que loop usa rcx, ecx o cx como contador ( decrementa y chekea si esta en cero)
    mov     esp, __STACK_END_32 ; Vuelvo a apuntar con el stack pointer al final

    ;;;;;;;;;;;;;   Copio system tables 32b  (0x00100000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ebp
    mov     ebp, esp
    push    __SYS_SIZE__
    push    __SYS_TABLES_VMA
    push    __SYS_TABLES_LMA
    call    __fast_memcpy_rom

    leave

    cmp eax, 1
    jne .guard

    o32 lgdt [_gdtr]
    lidt [_idtr]
    xchg bx, bx

    ;;;;;;;;;;;;;   Copio nucleo 32b  (0x00200000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ebp         ; guardo el valor de ebp
    mov     ebp, esp    ; apunto al valor del stack pointer
    ;primero pusheo el ultimo parametro de la funcion hasta el primero
    push    __NUCLEO_SIZE__
    push    __NUCLEO_VMA
    push    __NUCLEO_LMA  
    call    __fast_memcpy_rom

    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     .guard 

    ;;;;;;;;;;;;;   Copio funciones 32b  (0x00000000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __TECLADO_FUNC_SIZE_
    push    __TECLADO_FUNC_VMA
    push    __TECLADO_FUNC_LMA
    call    __fast_memcpy_rom

    ;;;;;;;;;;;;;   Copio datos 32b  (0x00202000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;


    push    ebp
    mov     ebp, esp
    push    __DATOS_SIZE__
    push    __DATOS_VMA
    push    __DATOS_LMA
    call    __fast_memcpy_rom

    leave

    cmp eax, 1
    jne .guard


    ; -------------- Configuro PIC ----------------

    call    InitPIC

    ; ----------------------------------------------

    jmp CS_SEL_32:start32
 

 ;-------------- Funcion de salto por error ------------------------------------

    .guard:
        hlt
        jmp .guard


;--------------------------------------------------------------------------------
; IDT INICIALIZACION
;--------------------------------------------------------------------------------

%define PIC1_COMMAND	0x20
%define PIC1_DATA	    0x21
%define PIC2_COMMAND	0xA0
%define PIC2_DATA	    0xA1

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
    out PIC2_DATA,al	;Enviar máscara al primer PIC
    STI
    
	ret
