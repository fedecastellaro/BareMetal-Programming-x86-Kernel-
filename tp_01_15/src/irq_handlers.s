%include "inc/procesor-flags.h"

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
GLOBAL isr_int_0x80

EXTERN DS_SEL_KERNEL

EXTERN _grabar
EXTERN _tabla_aux
EXTERN _acumular
EXTERN __DATOS_VMA
EXTERN task1

EXTERN  __TASK0_DIR_PAG_START
EXTERN  __TASK1_DIR_PAG_START
EXTERN  __TASK2_DIR_PAG_START
EXTERN  __TASK_CONTEXT_VMA

EXTERN  CS_SEL_USER
EXTERN  DS_SEL_USER
EXTERN  __STACK_TASK0_US_VMA
EXTERN  __SIMD_CONTEXT_VMA
EXTERN 	CantDigitos
EXTERN 	ContTarea1
EXTERN  ContTarea2
EXTERN  TareaActual
EXTERN  __set_PageTable
EXTERN  __PF_NEW_DIR_VMA
EXTERN  flag_task0_off
EXTERN  cantidad_de_pag_added
EXTERN  td3_hlt
EXTERN  td3_print
EXTERN  td3_read

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
    mov dx,14              ; muestro numero de interrupcion

    pop eax                ; Resguardo el valor del error de la pila
    mov ebx, CR2           ; Guardo la pagina que generó el error (direccion VMA a paginar)

    cmp eax,0              ; Lo comparo con 0 == Página no accesible/no paginada!
                           ; Para empezar, sólo voy a atender ese caso
    jz  Agregar_pagina_new ; Si se debe a ese error, salto a la rutina de nueva pagina
    jmp default_isr        ; Si se debe a otro error, por ahora no es posible solucionarlo
    
Agregar_pagina_new:
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    mov  eax, 0x1000        ; Armo tareas cada 4k
    mov  ebx, [cantidad_de_pag_added]   ; Salto "n" cantidad de paginas de 4k, segun cuántas ya he hecho
    mul  ebx
    add  eax, __PF_NEW_DIR_VMA    ; Acá ya tengo la direccion fisica preparada
    push eax                ; La pusheo en la pila como argumento de la funcion
    push ebx
    push eax                ; la cargo en la pila como argumento de la funcion
    mov  eax, CR3           ; cargo la CR3 de la task que genero el error
    push eax                ; la cargo en la pila como argumento de la funcion
    call __set_PageTable
    leave

    inc  ebx                ;Incremento y guardo la variable de páginas agregadas
    mov  [cantidad_de_pag_added], bx

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
;    xchg bx,bx
    clts                            ;Clear Task Switch -> CR0.TS = 0
    fxrstor [__SIMD_CONTEXT_VMA]   ;Cargamos los valores de los registros SIMD a partir de su contexto
    popad
    iret



isr_tick:
    push eax                            ;Cargo en la pila eax
    mov ax,ds                           
    movzx eax,ax 
    push eax                            ;Pusheo ds a la pila
    
    mov al,0x20                         ;End of Interrupt
    out 0x20,al

    inc BYTE [ContTarea1]               ;Incremento ContTarea1 (interrumpe cada 10mseg)
    inc BYTE [ContTarea2]               ;Incremento ContTarea2 (interrumpe cada 10mseg)
    
    
    mov eax,cr0                         ;Chequeo bit CR0.3 TS (Task Switch)
    test eax,8                          ;1000b
    jnz sin_SIMD                        ;Si no es cero -> resguardo el contexto SIMD
    fxsave [__SIMD_CONTEXT_VMA]         ;Guardamos contexto de los registros SIMD solo si TS = 0
    
    sin_SIMD:
    mov eax,cr0                         ;Pongo el bit CR0.3 TS (Task Switch) a 1
    or eax,0x08                         ;1000b
    mov cr0,eax                         
    

    cmp BYTE [ContTarea1],10            ;Comparo para ver si ContTarea1 esta en 10 -> 100mseg
    je ResetContTarea1                  ;Salto a Guardar_Contexto_Tarea_1 si no es cero

    cmp BYTE [ContTarea2],20            ;Comparo para ver si ContTarea2 esta en 20 -> 200mseg
    je ResetContTarea2                  ;Salto a Guardar_Contexto_Tarea_2 si no es cero

    cmp BYTE [TareaActual],0
    je Check_Task_0_state


    Check_Task_0_state:
    cmp BYTE [flag_task0_off], 0       ; Cuando este flag está en cero, significa que de el task0 NO se está ejecutando
                                       ; Este flag sólo lo setean las tareas antes de ser ejecutadas.
    je Cambio_A_task0                  ; Cuando este flag está en uno, significa que tengo que hacer el cambio de contexto al task 0

    ;Si llego acá estoy en la misma tarea. No hay context switch
    pop eax
    pop eax
    iret


    Cambio_A_task0:
    cmp BYTE [flag_task0_off], 1
    je CambioTarea


    ResetContTarea1:
   ; xchg bx,bx
    cmp BYTE [flag_task0_off], 0
    mov BYTE [ContTarea1],1
    mov BYTE [TareaActual],1
    jmp CambioTarea

    ResetContTarea2:
    ;xchg bx,bx
    cmp BYTE [flag_task0_off], 0
    mov BYTE [ContTarea2],0
    mov BYTE [TareaActual],2
    jmp CambioTarea


    CambioTarea:
    mov eax,__TASK_CONTEXT_VMA    ;Apunto al contexto de la tarea. Son todos los mismo, pero con distinta CR3! 
        
    mov dword [eax + OFFSET_EBX],ebx    ;Guardo los valores actuales de los registros en el contexto 
    mov dword [eax + OFFSET_ECX],ecx
    mov dword [eax + OFFSET_EDX],edx
    mov dword [eax + OFFSET_ESI],esi
    mov dword [eax + OFFSET_EDI],edi
    mov dword [eax + OFFSET_EBP],ebp
        
    pop ecx                     
    mov dword [eax + OFFSET_DS],ecx     ;Saco de la pila ds y lo guardo en el contexto
    pop ecx
    mov dword [eax + OFFSET_EAX],ecx    ;Saco de la pila eax y lo guardo en el contexto
    mov dword [eax + OFFSET_ESP0],esp   ;Guardo el valor de esp en el contexto
    mov ecx,[eax + OFFSET_SIG_CR3]      ;Cargo siguiente tarea a correr
        
    mov cr3,ecx                         ;Cargo CR3 con el nuevo directorio
           
    mov eax,__TASK_CONTEXT_VMA          ;Apunto al contexto VMA de la tarea -> 0x00600000 ( en cada context switch tengo CR3 distinto!)
        
    mov esp,[eax + OFFSET_ESP0]         ;Cargo esp a partir del contexto
    mov ecx,[eax + OFFSET_PRIM_EJEC]    ;Cargo ecx con la primera ejecucion 
    cmp ecx,1                           ;Comparo con 1
    je no_es_primer_ejecucion           ;Si es 1 -> salto y tengo que cargar en la pila cs, eflags y eip
    
    mov ecx,[eax + OFFSET_DS]           ;Chequeo si es PL=0 o PL=3
    cmp ecx,0x10                        ;Comparo
    je CPL0_nivel_0                     ;Si es PL=0 -> salto
    
    mov ecx,DS_SEL_USER                  ;SS3
    push ecx                            ;Pusheo a la pila
    mov ecx,__STACK_TASK0_US_VMA        ;Direccion lineal final pila de usuario tarea ( SON LA MISMA PARA LOS 3)
    push ecx                            ;Pusheo a la pila
    
    mov ecx,[eax + OFFSET_EFLAGS]       ;Desde el contexto, cargamos la pila
    push ecx                            ;Pusheo a la pila
    mov ecx,CS_SEL_USER                 ;Cargo CS de la pila con CS de PL=3
    push ecx                            ;Pusheo a la pila
    mov ecx,[eax + OFFSET_EIP]          ;Cargo EIP
    push ecx                            ;Pusheo a la pila
    mov dword [eax + OFFSET_PRIM_EJEC],1 ;Ya no es primera ejecucion
    jmp no_es_primer_ejecucion          ;Salto
    
    CPL0_nivel_0:
        mov ecx,[eax + OFFSET_EFLAGS]   ;Cargo eflags
        push ecx                        ;Pusheo a la pila
        mov ecx,[eax + OFFSET_CS]       ;Cargo cs
        push ecx                        ;Pusheo a la pila
        mov ecx,[eax + OFFSET_EIP]      ;Cargo eip
        push ecx                        ;Pusheo a la pila
        mov dword [eax + OFFSET_PRIM_EJEC],1 ;Ya no es primera ejcucion
        
    no_es_primer_ejecucion:
        mov ecx,[eax + OFFSET_ECX]      ;Cargo un registro general cualquiera
        push ecx                        ;Lo pongo en la pila, para no perder su valor
        mov ecx,eax                     ;Puntero al contexto
            
        mov eax,[ecx + OFFSET_EAX]      ;Cargo todos los registros con los valores del contexto
        mov ebx,[ecx + OFFSET_EBX]
        mov edx,[ecx + OFFSET_EDX]
        mov esi,[ecx + OFFSET_ESI]
        mov edi,[ecx + OFFSET_EDI]
        mov ebp,[ecx + OFFSET_EBP]
        mov es,[ecx + OFFSET_ES]
        mov ds,[ecx + OFFSET_DS]
        pop ecx                         ;Recupero el valor de ecx
        jmp Fin_ManejadorTimer          ;Salto


    Fin_ManejadorTimer:
        iret                                    ;Fin de la interrupcion


; Mi humilde handler para antender las interrupciones 80h

isr_int_0x80:
    cmp eax, _TD3_HLT
    je td3_hlt

    cmp eax, _TD3_READ
    je td3_read

    cmp eax, _TD3_WRITE
    je td3_print

    iret


