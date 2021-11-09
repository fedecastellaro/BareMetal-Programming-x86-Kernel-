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

EXTERN  __TASK0_DIR_PAG_START
EXTERN  __TASK1_DIR_PAG_START
EXTERN  __TASK2_DIR_PAG_START

EXTERN  TSS_task_0
EXTERN  TSS_task_1
EXTERN  TSS_task_2
EXTERN  __TSS_BASICA


EXTERN 	BufferTeclado
EXTERN 	IndiceTeclaLoop
EXTERN 	IndiceTeclaInt
EXTERN 	IndiceTablaDigitos
EXTERN 	CantDigitos
EXTERN 	CantPalabras
EXTERN 	BufferTablaTeclado
EXTERN 	IndiceBufferTeclado
EXTERN 	ContTarea1
EXTERN  ContTarea2
EXTERN  FlagTimer
EXTERN  Suma_1
EXTERN  SumaPrint_1
EXTERN  Suma_2
EXTERN  SumaPrint_2
EXTERN  CantPag_PF
EXTERN  TareaActual
EXTERN  TareaProx
EXTERN registros_SIMD_tarea_1
EXTERN registros_SIMD_tarea_2
EXTERN ultima_tarea_xmm

;Resumen de lo que hago acá:

;Tengo tres funciones en funtions.c:

;_acumular_en_buffer: Guarda todas las teclas que se presionan en __TABLE_INIT_VMA + 30

;_acumular_en_tabla_aux: Guarda todos los numeros que se presionan (y esten en el orden correcto) en una tabla de 16 bytes en __TABLE_INIT_VMA + 20

;_acumular_en_tabla_fin: Copia los ultimos 8 numeros que se presionaron (y que estan en la tabla aux) en la tabla final en __TABLE_INIT_VMA esp
;Apreto cualquier tecla, ordena y guarda los numeros si se los presiona en el orden correcto, y cuando apreto enter guarda los numeros
;en la posicion de memoria de 0x00210000, respetando el orden pedido ( MSB en cero)

%define IDLE        0
%define RUNNING     1
%define WAITING     2

USE32
SECTION .isr


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
    mov dx,13
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



isr7_handler_NM: 		;Interrupt 7—Device Not Available Exception (#NM)
        pushad
        mov     eax, cr0
        AND     eax,0xfffffff7
        mov     cr0,eax
        mov     eax, cr3
        cmp     dword eax, [ultima_tarea_xmm]       ; si es mi cr3, los registros estan cargados (no tengo que hacer nada)
        je      fin_NM
        cmp     dword eax, __TASK1_DIR_PAG_START            ; veo si es la tarea 1
        je      actualizo_tarea_1


actualizo_tarea_2:                                      ; si hay cambio de cr3 y no es la tarea 1, entonces es la 2
        fxsave  [registros_SIMD_tarea_2]
        fxrstor [registros_SIMD_tarea_1]
        mov     dword [ultima_tarea_xmm], eax       ; actualizo la ultima tarea
        jmp     fin_NM


actualizo_tarea_1:
        fxsave  [registros_SIMD_tarea_1]
        fxrstor [registros_SIMD_tarea_2]
        mov     dword [ultima_tarea_xmm], eax       ; actualizo la ultima tarea
        jmp     fin_NM

fin_NM:
    popad
    iret



isr_tick:
    push eax                    ;Salvo eax
    mov al,0x20                 ;EOI
    out 0x20,al
    
    inc BYTE [ContTarea1]       ;Incremento ContTarea1 (interrumpe cada 10mseg)
    inc BYTE [ContTarea2]       ;Incremento ContTarea2 (interrumpe cada 10mseg)
    
    cmp BYTE [ContTarea1],10    ;Comparo para ver si ContTarea1 esta en 10 -> 100mseg
    je Ejecutar_Tarea_1         ;Si esta en 10 -> salto a ejecutar la Tarea 1

    cmp BYTE [ContTarea2],20    ;Comparo para ver si ContTarea2 esta en 20 -> 200mseg
    je  Ejecutar_Tarea_2        ;Si esta en 20 -> salto a ejecutar la Tarea 2

    jmp Ejecutar_Idle_Tarea_0   ;Salto a ejecutar Idle Tarea 0

Ejecutar_Idle_Tarea_0:
           
    mov BYTE [TareaProx],0      ;Tarea proxima a ejecutar: Tarea 0
    
    cmp BYTE [TareaActual],1    ;Comparo para ver si TareaActual es 1
    je  Contexto_Tarea_1        ;Si es 1 -> salto a salvar su contexto
    cmp BYTE [TareaActual],2    ;Comparo para ver si TareaActual es 2
    je  Contexto_Tarea_2        ;Si es 2 -> salto a salvar su contexto
    jmp MismaTarea              ;Salto a MismaTarea

Ejecutar_Tarea_1:
    mov BYTE [ContTarea1],0     ;Reseteo contador de Tarea 1
    mov BYTE [TareaProx],1      ;Tarea proxima a ejecutar: Tarea 1
    
    cmp BYTE [TareaActual],1    ;Comparo para ver si TareaActual es 1
    je  MismaTarea              ;Salto a MismaTarea
    cmp BYTE [TareaActual],2    ;Comparo para ver si TareaActual es 2
    je  Contexto_Tarea_2        ;Si es 2 -> salto a salvar su contexto
    jmp Contexto_Tarea_0        ;Salto a salvar su contexto

Ejecutar_Tarea_2:
    mov BYTE [ContTarea2],0     ;;Reseteo contador de Tarea 2
    mov BYTE [TareaProx],2      ;Tarea proxima a ejecutar: Tarea 2
    
    cmp BYTE [TareaActual],1    ;Comparo para ver si TareaActual es 1
    je  Contexto_Tarea_1        ;Si es 1 -> salto a salvar su contexto
    cmp BYTE [TareaActual],2    ;Comparo para ver si TareaActual es 2
    je  MismaTarea              ;Si es 2 -> salto a MismaTarea
    jmp Contexto_Tarea_0        ;Salto a salvar su contexto

Contexto_Tarea_0:
    pop eax
    
    call Guardar_Contexto_Tarea_0 ;Llamo a Guardar_Contexto
    add esp,12                  ;Obtengo la Dir de retorno de la pila
    
    cmp BYTE [TareaProx],1      ;Comparo para ver si TareaProx es 1
    je Cambiar_a_Tarea_1        ;Si es 1 -> salto a cambiar de tarea
    cmp BYTE [TareaProx],2      ;Comparo para ver si TareaProx es 1
    je Cambiar_a_Tarea_2        ;Si es 2 -> salto a cambiar de tarea
    jmp Cambiar_a_Tarea_0       ;Salto a cambiar de tarea

Contexto_Tarea_1:
    pop eax
    
    call Guardar_Contexto_Tarea_1 ;Llamo a Guardar_Contexto
    add esp,12                  ;Obtengo la Dir de retorno de la pila
    
    cmp BYTE [TareaProx],1      ;Comparo para ver si TareaProx es 1
    je Cambiar_a_Tarea_1        ;Si es 1 -> salto a cambiar de tarea
    cmp BYTE [TareaProx],2      ;Comparo para ver si TareaProx es 1
    je Cambiar_a_Tarea_2        ;Si es 2 -> salto a cambiar de tarea
    jmp Cambiar_a_Tarea_0       ;Salto a cambiar de tarea

Contexto_Tarea_2:
    pop eax
    
    call Guardar_Contexto_Tarea_2 ;Llamo a Guardar_Contexto
    add esp,12                  ;Obtengo la Dir de retorno de la pila
    
    cmp BYTE [TareaProx],1      ;Comparo para ver si TareaProx es 1
    je Cambiar_a_Tarea_1        ;Si es 1 -> salto a cambiar de tarea
    cmp BYTE [TareaProx],2      ;Comparo para ver si TareaProx es 2
    je Cambiar_a_Tarea_1        ;Si es 2 -> salto a cambiar de tarea
    jmp Cambiar_a_Tarea_0       ;Salto a cambiar de tarea

Cambiar_a_Tarea_0:
    mov eax,__TASK0_DIR_PAG_START ;Cargo __TASK0_DIR_PAG_START en eax
    mov cr3,eax                 ;Cargo cr3 con eax 
    mov  eax, cr0
    or   eax,8
    mov cr0,eax
    mov esp,[TSS_task_0 + 0x38] ;Recupero el estado de la pila
    call Retornar_Contexto_Tarea_0 ;Llamo a retornar contexto
    mov BYTE [TareaActual],0    ;Tarea actual: Tarea 0
    jmp Fin_ManejadorTimer      ;Salto a Fin_ManejadorTimer

Cambiar_a_Tarea_1:
    mov eax,__TASK1_DIR_PAG_START ;Cargo __TASK1_DIR_PAG_START en eax
    mov cr3,eax
    mov  eax, cr0
    or   eax,8
    mov cr0,eax                 ;Cargo cr3 con eax 
    mov esp,[TSS_task_1 + 0x38] ;Recupero el estado de la pila
    call Retornar_Contexto_Tarea_1 ;Llamo a retornar contexto
    mov BYTE [TareaActual],1    ;Tarea actual: Tarea 1
    jmp Fin_ManejadorTimer      ;Salto a Fin_ManejadorTimer

Cambiar_a_Tarea_2:
    mov eax,__TASK2_DIR_PAG_START ;Cargo __TASK2_DIR_PAG_START en eax
    mov cr3,eax
    mov  eax, cr0
    or   eax,8
    mov cr0,eax                 ;Cargo cr3 con eax
    mov esp,[TSS_task_2 + 0x38] ;Recupero el estado de la pila
    call Retornar_Contexto_Tarea_2 ;Llamo a retornar contexto
    mov BYTE [TareaActual],2    ;Tarea actual: Tarea 2
    jmp Fin_ManejadorTimer      ;Salto a Fin_ManejadorTimer

MismaTarea: 
    pop eax
    jmp Fin_ManejadorTimer      ;Salto a Fin_ManejadorTimer

Fin_ManejadorTimer:
    ;mov al,0x20                 ;Envío End of Interrupt al PIC
    ;out 0x20,al
    iret                        ;Fin de la interrupción

;--------------------------------------------------------------------------------
; Funciones para guardar el contexto de la tarea
;--------------------------------------------------------------------------------
    ;STACK
    ;x      Dir de retorno
    ;x+4    Dir de EIP de programa
    ;x+8    CS 
    ;x+12   EFLAGS
    ;Las TSS siempre se encontraran en la misma dir lineal (al inicio de la seccion .data) 
Guardar_Contexto_Tarea_0:
    mov [TSS_task_0 + 0x28],eax  ;Guardo los registros de uso general
    mov [TSS_task_0 + 0x34],ebx
    mov [TSS_task_0 + 0x2c],ecx
    mov [TSS_task_0 + 0x30],edx
    mov [TSS_task_0 + 0x3c],ebp
    mov [TSS_task_0 + 0x40],esi
    mov [TSS_task_0 + 0x44],edi
    mov eax,[esp+4]
    mov [TSS_task_0 + 0x20],eax
    mov eax,[esp+8]
    mov [TSS_task_0 + 0x4C],ax
    mov eax,[esp+12]
    mov [TSS_task_0 + 0x24],eax
    mov [TSS_task_0 + 0x48],es
    mov [TSS_task_0 + 0x4C],cs
    mov [TSS_task_0 + 0x50],ss
    mov [TSS_task_0 + 0x54],ds
    mov [TSS_task_0 + 0x58],fs
    mov [TSS_task_0 + 0x5C],gs
    mov ebp,esp     ;La posicion de la pila es la actual +16 ya que los registros eip,eflags y cs estan resguardados
    add ebp,0x10
    mov [TSS_task_0 + 0x38],ebp    ;Guardo el estado de la pila (esp)
    ret

Guardar_Contexto_Tarea_1:
    mov [TSS_task_1 + 0x28],eax  ;Guardo los registros de uso general
    mov [TSS_task_1 + 0x34],ebx
    mov [TSS_task_1 + 0x2c],ecx
    mov [TSS_task_1 + 0x30],edx
    mov [TSS_task_1 + 0x3c],ebp
    mov [TSS_task_1 + 0x40],esi
    mov [TSS_task_1 + 0x44],edi
    mov eax,[esp+4]
    mov [TSS_task_1 + 0x20],eax
    mov eax,[esp+8]
    mov [TSS_task_1 + 0x4C],ax
    mov eax,[esp+12]
    mov [TSS_task_1 + 0x24],eax
    mov [TSS_task_1 + 0x48],es
    mov [TSS_task_1 + 0x4C],cs
    mov [TSS_task_1 + 0x50],ss
    mov [TSS_task_1 + 0x54],ds
    mov [TSS_task_1 + 0x58],fs
    mov [TSS_task_1 + 0x5C],gs
    mov ebp,esp     ;La posicion de la pila es la actual +16 ya que los registros eip,eflags y cs estan resguardados
    add ebp,0x10
    mov [TSS_task_1 + 0x38],ebp    ;Guardo el estado de la pila (esp)
    ret

Guardar_Contexto_Tarea_2:
    mov [TSS_task_2 + 0x28],eax  ;Guardo los registros de uso general
    mov [TSS_task_2 + 0x34],ebx
    mov [TSS_task_2 + 0x2c],ecx
    mov [TSS_task_2 + 0x30],edx
    mov [TSS_task_2 + 0x3c],ebp
    mov [TSS_task_2 + 0x40],esi
    mov [TSS_task_2 + 0x44],edi
    mov eax,[esp+4]
    mov [TSS_task_2 + 0x20],eax
    mov eax,[esp+8]
    mov [TSS_task_2 + 0x4C],ax
    mov eax,[esp+12]
    mov [TSS_task_2 + 0x24],eax
    mov [TSS_task_2 + 0x48],es
    mov [TSS_task_2 + 0x4C],cs
    mov [TSS_task_2 + 0x50],ss
    mov [TSS_task_2 + 0x54],ds
    mov [TSS_task_2 + 0x58],fs
    mov [TSS_task_2 + 0x5C],gs
    mov ebp,esp     ;La posicion de la pila es la actual +16 ya que los registros eip,eflags y cs estan resguardados
    add ebp,0x10
    mov [TSS_task_2 + 0x38],ebp    ;Guardo el estado de la pila (esp)
    ret

;--------------------------------------------------------------------------------
; Funciones para retornar el contexto de la tarea
;--------------------------------------------------------------------------------
    ;STACK
    ;x      Dir de retorno
    ;x+4    Dir de EIP de programa
    ;x+8    CS 
    ;x+12   EFLAGS
    ;Las TSS siempre se encontraran en la misma dir lineal (al inicio de la seccion .data) 
Retornar_Contexto_Tarea_0:
    push eax                        ;Reservo 3 double word en memoria
    push eax
    push eax
    mov eax,[esp+12]                ;Direccion donde debia retornar
    mov [esp],eax

    mov es,[TSS_task_0 + 0x48]
    mov ss,[TSS_task_0 + 0x50]
    mov ds,[TSS_task_0 + 0x54]
    mov fs,[TSS_task_0 + 0x58]
    mov gs,[TSS_task_0 + 0x5C]

    mov eax,[TSS_task_0 + 0x20]
    mov [esp+4],eax
    xor eax,eax
    mov ax,[TSS_task_0 + 0x4C]
    mov [esp+8],eax
    mov eax,[TSS_task_0 + 0x24]
    or eax, 0x0202                  ;Enable int
    mov [esp+12],eax

    mov eax,[TSS_task_0 + 0x28]    ;Retorno los registros de uso general
    mov ebx,[TSS_task_0 + 0x34]
    mov ecx,[TSS_task_0 + 0x2C]
    mov edx,[TSS_task_0 + 0x30]
    mov ebp,[TSS_task_0 + 0x3C] 
    mov esi,[TSS_task_0 + 0x40]
    mov edi,[TSS_task_0 + 0x44]

    ret


Retornar_Contexto_Tarea_1:
    push eax                        ;Reservo 3 double word en memoria
    push eax
    push eax
    mov eax,[esp+12]                ;Direccion donde debia retornar
    mov [esp],eax

    mov es,[TSS_task_1 + 0x48]
    mov ss,[TSS_task_1 + 0x50]
    mov ds,[TSS_task_1 + 0x54]
    mov fs,[TSS_task_1 + 0x58]
    mov gs,[TSS_task_1 + 0x5C]

    mov eax,[TSS_task_1 + 0x20]
    mov [esp+4],eax
    xor eax,eax
    mov ax,[TSS_task_1 + 0x4C]
    mov [esp+8],eax
    mov eax,[TSS_task_1 + 0x24]
    or eax, 0x0202                  ;Enable int
    mov [esp+12],eax

    mov eax,[TSS_task_1 + 0x28]    ;Retorno los registros de uso general
    mov ebx,[TSS_task_1 + 0x34]
    mov ecx,[TSS_task_1 + 0x2C]
    mov edx,[TSS_task_1 + 0x30]
    mov ebp,[TSS_task_1 + 0x3C] 
    mov esi,[TSS_task_1 + 0x40]
    mov edi,[TSS_task_1 + 0x44]

    ret


Retornar_Contexto_Tarea_2:
    push eax                        ;Reservo 3 double word en memoria
    push eax
    push eax
    mov eax,[esp+12]                ;Direccion donde debia retornar
    mov [esp],eax

    mov es,[TSS_task_2 + 0x48]
    mov ss,[TSS_task_2 + 0x50]
    mov ds,[TSS_task_2 + 0x54]
    mov fs,[TSS_task_2 + 0x58]
    mov gs,[TSS_task_2 + 0x5C]

    mov eax,[TSS_task_2 + 0x20]
    mov [esp+4],eax
    xor eax,eax
    mov ax,[TSS_task_2 + 0x4C]
    mov [esp+8],eax
    mov eax,[TSS_task_2 + 0x24]
    or eax, 0x0202                  ;Enable int
    mov [esp+12],eax

    mov eax,[TSS_task_2 + 0x28]    ;Retorno los registros de uso general
    mov ebx,[TSS_task_2 + 0x34]
    mov ecx,[TSS_task_2 + 0x2C]
    mov edx,[TSS_task_2 + 0x30]
    mov ebp,[TSS_task_2 + 0x3C] 
    mov esi,[TSS_task_2 + 0x40]
    mov edi,[TSS_task_2 + 0x44]

    ret
