
EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla
EXTERN __SIMD_CONTEXT_VMA
GLOBAL 	TareaActual

GLOBAL task1
GLOBAL largo4
GLOBAL msg4
GLOBAL resultado_suma_1

%define _START_TABLA_DIGITO 0x1210070
%define _TD3_HLT    1
%define _TD3_READ   2
%define _TD3_WRITE  3


USE32
section .task1_txt


task1:
init_tarea_1:
    
    ;--------------------- leo y sumo datos ---------------------------;

    mov ecx, [cantidad_en_tabla]  ; -> cargo variable (originalmente en cero)
    mov edi, numeros_leidos_t1    ; -> cargo puntero con la posición a donde copiar. Tabla de digitos propia de la tarea.
    mov eax, _TD3_READ
    int 0x80

    ; Cuando vuelvo de TD3_READ, en EAX tengo carga la cantidad de digitos que hay cargados en la tabla
    xor  ecx, ecx
    mov  ecx, [cantidad_sumados]   ; retomo desde donde me quede en la suma (numero_actual_1)
                                   ; esto es para que el procesador retome del punto donde estaba antes

    cmp     eax, ecx
    jne     loop_suma_1
    jmp     fin_suma_1

loop_suma_1:
    movq      mm0, qword[resultado_suma_1]           ; Cargo el resultado de la suma que se tiene hasta el momento
    movq      mm1, qword[numeros_leidos_t1 + ecx*8]  ; Cargo el nuevo numero a sumar
    paddq     mm0, mm1                               ; Sumo
    movq      qword[resultado_suma_1], mm0           ; guardo el resultado en la variable de la suma total

    inc     ecx
    mov     [cantidad_sumados], ecx                 ; Resguardo cuántos numeros de la tabla tengo sumados hasta el momento

    cmp     ecx, ebx                 ; Comparo la cantidad de numeros sumados con la cantidad de numeros dentro de la tabla
    jb      loop_suma_1

fin_suma_1:
    mov  [cantidad_en_tabla], eax  ; -> TD3_READ devuelve la cantidad de digitos en la tabla, y lo guardo para la proxima


    ;--------------------- Muestro datos en pantalla ---------------------------;

    ;Empiezo a cargar los registros con los valores necesarios para imprimir en pantalla

    mov ebx, largo4 + 2       ; punto donde empezar a escribir en pantalla  
    mov ecx, resultado_suma_1   ; puntero a la variable a imprimir
    mov eax, _TD3_WRITE
    int 0x80

    ;--------------------- Pongo al procesador en HLT ---------------------------;

    mov eax, _TD3_HLT
    int 0x80

    jmp     init_tarea_1



;********************************************************************************
; Tarea 1 BSS
;********************************************************************************
SECTION 	.task1_bss      nobits



;********************************************************************************
; Tarea 1 Data
;********************************************************************************
SECTION 	.task1_data 	

msg4: db 'Suma task 1:',0
largo4 EQU $ - msg4

resultado_suma_1:
                resb 16

cantidad_sumados dd 0

numeros_leidos_t1:
                resb 512 ; reservo 512 bytes : 64 palabras de 8 bytes

cantidad_en_tabla:
                resb 1

