
GLOBAL _acumular
GLOBAL _tabla_aux
GLOBAL _grabar
Indic
EXTERN __TABLA_DIGITO_VMA
EXTERN _acumular_en_tabla_aux
EXTERN _acumular_en_tabla_fin
EXTERN _acumular_en_buffer
EXTERN __printf_sum
EXTERN fin_int
EXTERN suma_a_hexa
EXTERN clean_numeros
EXTERN 	Cant_digitos_tabla
EXTERN indice_final
EXTERN indice

USE32
SECTION .isr

_acumular:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x30   ; guarda todos los numeros que se presionaron en esta posicion de memoria
    call    _acumular_en_buffer     
    leave

    jmp fin_int

_tabla_aux:
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x20
    call    _acumular_en_tabla_aux      ; cambiar a guardar en tabla ( maximo 9 bytes)
    leave

    jmp _acumular

_grabar: ; entro a este punto cuando presiono el enter
    push    ebp
    mov     ebp, esp
    push    eax
    push    __TABLA_DIGITO_VMA + 0x30
    call    _acumular_en_buffer ; guardo el enter en el buffer de teclas apretadas.
    leave

    ; Verifico que no haya devuelto ningun error la funcion anterior:
    ; Codigo de error  ->  eax = 0x38
    ; Si no hubo error, devuelve el ultimo numero anteriormente presionado
    cmp eax, 0x9
    jg fin_int

    ; Si no hubo error continua con el programa
    push    ebp
    mov     ebp, esp
    push    __TABLA_DIGITO_VMA
    push    __TABLA_DIGITO_VMA + 0x20 ; paso todos los numeros a la tabla definitiva
    call    _acumular_en_tabla_fin
    leave

    ;Llamo a la funcion que guarda el num en hexa en la tabla
    ;Tengo que pasarle la posicion de la tabla donde guardo
    ;los numeros ingresados.
    ; Direccion : __TABLA_DIGITO_VMA + 0x70 +(cant_digitos_tabla*8) -> xq numeros de 8 bytes
    mov     eax, [Cant_digitos_tabla]   ; cargo la cantidad de digitos que tengo
    mov     ecx, 8             ; lo multiplico por el offset de cada uno ( 8 bytes )
    mul     ecx
    add     eax, 0x70          ; lo guardo en el comienzo de mi tabla de paginas ( __TABLA_DIGITO_VMA + 0x70 )
    add     eax, __TABLA_DIGITO_VMA
    push    ebp                 
    mov     ebp, esp
    push    eax
    call    suma_a_hexa
    leave

    xor eax, eax    
    mov eax, [Cant_digitos_tabla] ; Incremento la variable que indica la cantidad de nueros ingresados
    inc eax
    mov [Cant_digitos_tabla], eax ; Guardo el nuevo valor de cantidad de digitos en tabla 
    xor eax, eax                  ; Limpio el valor para cargarle uno nuevo
    mov eax, [indice]             ; Cargo el valor del indice en eax
    mov [indice_final], eax       ; Cargo en la variable global del indice el nuevo valor ( lo utiliza la funcion printf dentro del td3_printf)

    push    ebp
    mov     ebp, esp
    call    clean_numeros       ; limpio los numeros del buffer para cargar los siguientes
    leave

    jmp fin_int
