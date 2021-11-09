
GLOBAL _acumular
GLOBAL _tabla_aux
GLOBAL _grabar

EXTERN __TABLE_INIT_VMA
EXTERN _acumular_en_tabla_aux
EXTERN _acumular_en_tabla_fin
EXTERN _acumular_en_buffer
EXTERN __printf_sum
EXTERN fin_int
EXTERN suma_a_hexa
EXTERN clean_numeros
USE32
SECTION .isr

_acumular:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLE_INIT_VMA + 0x30
    call    _acumular_en_buffer
    leave

    jmp fin_int

_tabla_aux:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLE_INIT_VMA + 0x20
    call    _acumular_en_tabla_aux ; cambiar a guardar en tabla ( maximo 9 bytes)
    leave

    jmp _acumular

_grabar:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLE_INIT_VMA + 0x30
    call    _acumular_en_buffer ; guardo el enter
    leave

    push    ebp
    mov     ebp, esp
    push    __TABLE_INIT_VMA
    push    __TABLE_INIT_VMA + 0x20
    call    _acumular_en_tabla_fin
    leave

    push    ebp
    mov     ebp, esp
    call    suma_a_hexa
    leave

    push    ebp
    mov     ebp, esp
    call    clean_numeros
    leave

    jmp fin_int
