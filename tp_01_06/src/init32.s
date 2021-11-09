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

EXTERN  __fast_memcpy
EXTERN  __fast_memcpy_rom

EXTERN  __DATOS_SIZE__
EXTERN  __DATOS_VMA
EXTERN  __DATOS_LMA

EXTERN  __TECLADO_FUNC_SIZE_
EXTERN  __TECLADO_FUNC_VMA
EXTERN  __TECLADO_FUNC_LMA



GLOBAL start32_launcher
;En este punto ya me encuentro en modo protegido!
start32_launcher:
    ;xchg    bx, bx
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

;    xchg bx, bx
    leave

    cmp eax, 1
    jne .guard

    xchg bx, bx
    jmp CS_SEL_32:start32
 

    .guard:
        hlt
        jmp .guard
