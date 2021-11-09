USE32
section .start32

EXTERN  DS_SEL
EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32
EXTERN  CS_SEL_32
EXTERN  kernel32_init
EXTERN  __KERNEL_32_LMA
EXTERN  __codigo_kernel32_size
EXTERN  __fast_memcpy
EXTERN  __fast_memcpy_rom
EXTERN  kernel32_code_size
EXTERN  __function_size
EXTERN  __FUNCTIONS_LMA
EXTERN  __KERNEL_32_VMA
EXTERN  __FUNCTIONS_VMA

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
        push    eax ; "pushea" (pisa) con ceros toda la memoria que compone el stack
        loop    .stack_init ; Recordar que loop usa rcx, ecx o cx como contador ( decrementa y chekea si esta en cero)
    
    mov     esp, __STACK_END_32 ; Vuelvo a apuntar con el stack pointer al final

    xchg    bx, bx
    ; armo un stack frame.
    push    ebp ; guardo el valor de ebp
    mov     ebp, esp ; apunto al valor del stack pointer
    ;primero pusheo el ultimo parametro de la funcion hasta el primero
    push    __function_size
    push    __FUNCTIONS_VMA
    push    __FUNCTIONS_LMA
    call    __fast_memcpy_rom
    xchg    bx, bx

    leave

    cmp eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne .guard 
    xchg bx, bx

    push    ebp
    mov     ebp, esp
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA  
    call __fast_memcpy_rom

    xchg bx, bx
    leave

    cmp eax, 1
    jne .guard

    xchg bx, bx
    jmp CS_SEL_32:kernel32_init

    .guard:
        hlt
        jmp .guard



