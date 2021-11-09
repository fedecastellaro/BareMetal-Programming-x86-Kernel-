
GLOBAL td3_hlt
GLOBAL td3_read
GLOBAL td3_print

EXTERN __printf_sum
EXTERN resultado_suma_1
EXTERN resultado_suma_2
EXTERN largo4
EXTERN largo5
EXTERN __TASK0_DIR_PAG_START
EXTERN __TASK1_DIR_PAG_START
EXTERN __TASK2_DIR_PAG_START
EXTERN Cant_digitos_tabla
EXTERN  __verificar_direccion
EXTERN  DS_SEL_KERNEL
EXTERN TareaActual
EXTERN flag_task0_off

%define  FILA_9   9
%define  FILA_10  10
%define  _START_TABLA_DIGITO  0x1210070
%define  _OK_       1
%define  _ERROR_    0
%define _TD3_HLT    1
%define _TD3_READ   2
%define _TD3_WRITE  3

USE32
SECTION .functions_rom

;************************************************************************
; unsigned int td3_read(void *buffer, unsigned int num_bytes);

;************************************************************************
td3_hlt:
    mov BYTE [flag_task0_off], 1
    mov BYTE [TareaActual],0
    sti
    hlt
    iret

;************************************************************************
; unsigned int td3_read(void *buffer, unsigned int num_bytes);

; edi -> direccion a hacer la copia
; ecx -> cantidad a imprimir

; return -> eax = Cantidad de elementos en tabla   
;        -> eax = 0 En caso de que haya un error de acceso a memoria ( sin privilegios)
;************************************************************************
td3_read:
    
    xor     eax, eax    ; inicializo ebx en cero
    xor     ebx, ebx    ; inicializo ebx en cero
    xor     edx, edx

    ; Verifico si la direccion a hacer la copia sea un lugar valido:
    mov     edx, cr3
    push    ecx
    push    edi

    push    ebp         ; Preparo los punteros para saltar a la funcion
    mov     ebp, esp
    push    edi         ; Cargo con la direccion lineal de la tarea
    push    edx         ; Cargo con la direccion de comienzo del DTP
    call    __verificar_direccion   ; Funcion que verifica que puedo acceder a mi tarea -> EAX = 1 (OK)
    leave                                                                              ;-> EAX = 0 (Error de permiso)        


    pop     edi         ; recupero los valores de los registros
    pop     ecx         ; recupero los valores de los registros

    mov     edx, _START_TABLA_DIGITO ; guardo en edx la posicion de comienzo de la tabla de digito

    cmp  eax, _OK_  ; Si pasa la verificación para poder acceder a memoria, realizo la tarea llamada
    je   copio
    jmp  error_direccion

copio:
    xor     eax, eax
    mov     eax, [edx + ebx*8+4]            ; obtengo parte baja del numero contenido en la tabla
    mov     [edi + ebx*8+4], eax            ; lo copio al buffer

    xor     eax, eax

    mov     eax, [edx + ebx*8]            ; obtengo parte baja del numero contenido en la tabla
    mov     [edi + ebx*8], eax            ; lo copio al buffer

    inc     ebx             ; incremento la variable que indica cantidad de numeros copiados

    cmp     ebx, ecx        ; Comparo si se llego a la cantidad que se pedia
    jle     copio           ; si la cantidad de bytes leidos es menor que el requerido, vuelvo a copiar

    mov     eax, [Cant_digitos_tabla]        ; devuelve la cantidad de numeros que hay en la tabla
    iret

;**********************************************************************
; unsigned int td3_print(void *buffer, unsigned int num_bytes);
; ECX ->    Puntero de la variable
; EBX ->    Numero
;**********************************************************************
td3_print:
    mov     edx, cr3    ; Me fijo en qué direccion fisica de directorio me encuentro

    push    ecx         ; Resguardo los valores de registro que utilizaré después.
    push    ebx         ; Resguardo los valores de registro que utilizaré después.

    push    ebp         ; Preparo los punteros para saltar a la funcion
    mov     ebp, esp
    push    ecx         ; Cargo con la direccion lineal de la tarea
    push    edx         ; Cargo con la direccion de comienzo del DTP
    call    __verificar_direccion   ; Funcion que verifica que puedo acceder a mi tarea -> EAX = 1 (OK)
    leave                                                                              ;-> EAX = 0 (Error de permiso)        

    pop  ebx             ; recupero los valores de los registros
    pop  ecx             ; recupero los valores de los registros
    mov  edx, cr3    ; recupero los valores de los registros
    cmp  eax, _OK_      ; Si pasa la verificación para poder acceder a memoria, realizo la tarea llamada
    je   print
    jmp  error_direccion

print:
    cmp edx, __TASK1_DIR_PAG_START  ; Me fijo en qué CR3 me encuentro para saber dónde tengo qeu mostrar en pantalla
    je print_task1
    cmp edx, __TASK2_DIR_PAG_START  ; Me fijo en qué CR3 me encuentro para saber dónde tengo qeu mostrar en pantalla
    je print_task2

    print_task1:    ; Uso mi funcion __printf_sum para mostrar el numero en mi pantalla ( pasa de la suma en decimal a Hexa )
    push    ebp
    mov     ebp, esp
;   push    dword [ecx +4]  ; Todavía no me anduvo bien la función para mostrar los 64 bits de la suma, asi que por ahora trabajo con 32
    push    dword [ecx]     ; Cargo el puntero con la direción de la variable con la suma total
    push    dword [ecx + 4]
    push    ebx             ; Cargo el offset donde tengo que imprimir en pantalla ( COLUMNA )
    push    FILA_9          ; Cargo la fila donde escribir
    call    __printf_sum
    leave
    iret

    print_task2:    ; Uso mi funcion __printf_sum para mostrar el numero en mi pantalla ( pasa de la suma en decimal a Hexa )
    push    ebp
    mov     ebp, esp
;   push    dword [ecx +4]  ; Todavía no me anduvo bien la función para mostrar los 64 bits de la suma, asi que por ahora trabajo con 32
    push    dword [ecx]     ; Cargo el puntero con la direción de la variable con la suma total ( LSB )
    push    dword [ecx + 4] ; (MSB)
    push    ebx             ; Cargo el offset donde tengo que imprimir en pantalla ( COLUMNA )
    push    FILA_10          ; Cargo la fila donde escribir
    call    __printf_sum
    leave
    iret



error_direccion:
    mov eax, _ERROR_  ; devuelve un eax = 0 en caso de error
    iret

solo_para_debug:
    xchg bx,bx
    iret