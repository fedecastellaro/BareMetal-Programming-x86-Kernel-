

EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla
GLOBAL resultado_suma_2
GLOBAL task2
GLOBAL largo5
GLOBAL msg5
EXTERN TareaActual


%define _START_TABLA_DIGITO 0x1210070

%define _TD3_HLT    1
%define _TD3_READ   2
%define _TD3_WRITE  3


USE32
section .task2_txt

task2:

init_tarea_2:

    ;--------------------- leo y sumo datos ---------------------------;

    mov ecx, [cantidad_en_tabla]  ; -> cargo variable (originalmente en cero)
    mov edi, numeros_leidos_t2    ; -> cargo puntero con la posición a donde copiar. Tabla de digitos propia de la tarea.
    mov eax, _TD3_READ
    int 0x80

    ; Cuando vuelvo de TD3_READ, en EAX tengo carga la cantidad de digitos que hay cargados en la tabla
    xor  ecx, ecx
    mov  ecx, [cantidad_sumados]   ; retomo desde donde me quede en la suma (numero_actual_1)
                                   ; esto es para que el procesador retome del punto donde estaba antes

    cmp     eax, ecx
    jne     loop_suma_2
    jmp     fin_suma_2

loop_suma_2:
    movq      mm0, qword[resultado_suma_2]           ; Cargo el resultado de la suma que se tiene hasta el momento
    movq      mm1, qword[numeros_leidos_t2 + ecx*8]  ; Cargo el nuevo numero a sumar
    paddusw   mm0, mm1                               ; Sumo
    movq      qword[resultado_suma_2], mm0           ; guardo el resultado en la variable de la suma total

    inc     ecx
    mov     [cantidad_sumados], ecx                  ; Resguardo cuántos numeros de la tabla tengo sumados hasta el momento

    cmp     eax, ecx                   ; Comparo la cantidad de numeros sumados con la cantidad de numeros dentro de la tabla
    jb     loop_suma_2

fin_suma_2:
    mov  [cantidad_en_tabla], eax  ; -> TD3_READ devuelve la cantidad de digitos en la tabla, y lo guardo para la proxima

    ;--------------------- Muestro datos en pantalla ---------------------------;

    ;Empiezo a cargar los registros con los valores necesarios para imprimir en pantalla
    mov ebx, largo5 + 2    ; variable a imprimir
    mov ecx, resultado_suma_2        ; punto donde empezar a escribir.
    mov eax, _TD3_WRITE         ; cargo en eax el syscall correspondiente al td3_write
    int 0x80

    ;--------------------- Pongo al procesador en HLT ---------------------------;


    mov eax, _TD3_HLT           ; cargo en eax el syscall correspondiente al td3_HLT
    int 0x80

    jmp     init_tarea_2


;********************************************************************************
; Tarea 2 BSS
;********************************************************************************
SECTION 	.task2_bss 	nobits



;********************************************************************************
; Tarea 2 Data
;********************************************************************************
SECTION 	.task2_data 	

msg5: db 'Suma task 2:',0
largo5 EQU $ - msg5

resultado_suma_2:
                resb 8
                
cantidad_sumados dd 0

cantidad_en_tabla:
                resb 1

numeros_leidos_t2:
                resb 512 ; reservo 512 bytes : 64 palabras de 8 bytes
