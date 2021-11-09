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

EXTERN  __TAREA1_SIZE__
EXTERN  __TAREA1_VMA
EXTERN  __TAREA1_LMA

EXTERN  _idtr
EXTERN  _gdtr

EXTERN  halted


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
    jne halted

    o32 lgdt [_gdtr]
    o32 lidt [_idtr]

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
    jne     halted 

    ;;;;;;;;;;;;;   Copio funciones 32b  (0x00000000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __TECLADO_FUNC_SIZE_
    push    __TECLADO_FUNC_VMA
    push    __TECLADO_FUNC_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     halted 
    ;;;;;;;;;;;;;   Copio datos 32b  (0x00202000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __DATOS_SIZE__
    push    __DATOS_VMA
    push    __DATOS_LMA
    call    __fast_memcpy_rom
    leave

    cmp eax, 1
    jne halted

    ; ----------------------------------------------

    ;;;;;;;;;;;;;   Copio tarea1_ datos  (0x00300000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __TAREA1_SIZE__
    push    __TAREA1_VMA
    push    __TAREA1_LMA
    call    __fast_memcpy_rom
    leave

    cmp eax, 1
    jne halted


    ; ----------------------------------------------
    push ebp
    mov ebp, esp
    mov cx, 100
    call PIT_Set_Counter0
    leave 

    ; ----------------------------------------------

    jmp CS_SEL_32:start32
 

 ;-------------- Funcion de salto por error ------------------------------------

    jmp halted


;--------------------------------------------------------------------------------
; IDT INICIALIZACION
;--------------------------------------------------------------------------------


PIT_Set_Counter0:
   push ax
   mov al, 00110100b
   out 43h, al             ;En 43h está el registro de control.
   mov ax, 1193            ;Los 3 contadores del PIT reciben una señal de clock de 1.19318[MHz] 
   mul cx                  ;1193 * cx / 1.19318[MHz] = 1000 / cx [int/seg]​
   out 40h, al             ; En 40h está el Counter 0.
   mov al, ah
   out 40h, al
   pop ax
   ret
