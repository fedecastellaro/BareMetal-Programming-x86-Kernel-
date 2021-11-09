
GLOBAL _acumular
GLOBAL _tabla_aux
GLOBAL _grabar

EXTERN __TABLA_DIGITO_VMA
EXTERN _acumular_en_tabla_aux
EXTERN _acumular_en_tabla_fin
EXTERN _acumular_en_buffer
EXTERN __printf_sum
EXTERN fin_int
EXTERN suma_a_hexa
EXTERN clean_numeros
EXTERN 	Cant_digitos_tabla


USE32
SECTION .isr

_acumular:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x30
    call    _acumular_en_buffer
    leave

    jmp fin_int

_tabla_aux:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x20
    call    _acumular_en_tabla_aux ; cambiar a guardar en tabla ( maximo 9 bytes)
    leave

    jmp _acumular

_grabar:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x30
    call    _acumular_en_buffer ; guardo el enter
    leave

    push    ebp
    mov     ebp, esp
    push    __TABLA_DIGITO_VMA
    push    __TABLA_DIGITO_VMA + 0x20
    call    _acumular_en_tabla_fin
    leave

    ;Llamo a la funcion que guarda el num en hexa en la tabla
    ;Tengo que pasarle la posicion de la tabla donde guardo
    ;los numeros ingresados.
    ; Direccion : __TABLA_DIGITO_VMA + 0x70 +(cant_digitos_tabla*8) -> xq numeros de 8 bytes
    
    mov     eax, [Cant_digitos_tabla]
    mov     ecx, 8
    mul     ecx
    add     eax, 0x70
    add     eax, __TABLA_DIGITO_VMA
    push    ebp
    mov     ebp, esp
    push    eax
    call    suma_a_hexa
    leave


    mov eax, [Cant_digitos_tabla] ; Incremento la variable que indica la cantidad de nueros ingresados
    inc eax
    mov [Cant_digitos_tabla], eax 

    push    ebp
    mov     ebp, esp
    call    clean_numeros
    leave

    jmp fin_int
