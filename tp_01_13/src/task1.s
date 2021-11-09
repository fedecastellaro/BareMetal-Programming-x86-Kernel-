
EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla

GLOBAL task1
GLOBAL TSS_task_1
GLOBAL largo4
GLOBAL msg4

USE32
section .task1_txt


task1:

init_tarea_1:
                xor     ecx, ecx
                mov     ecx, [cantidad_sumados]              ; retomo desde donde me quede en la suma (numero_actual_1)
                mov     eax, [Cant_digitos_tabla]
                cmp     [Cant_digitos_tabla], ecx
                jne     sumar_numeros_1
                jmp     fin_tarea_1


sumar_numeros_1:
                clc                                     ; limpio carry

loop_suma_1:

                mov     eax, [resultado_suma_1+4]       ; parte baja del resultado anterior (resultado_suma_1)
                mov     ebx, [0x1210070+ecx*8+4]          ; parte baja del nuevo numero
                adc     eax, ebx
                mov     [resultado_suma_1+4], eax

                mov     eax, [resultado_suma_1]              ; parte alta del resultado anterior
                mov     ebx, [0x1210070+ecx*8]            ; parte alta del nuevo numero
                adc     eax, ebx
                mov     [resultado_suma_1], eax

                inc     ecx
                inc     edi
                cmp     ecx, [Cant_digitos_tabla]
                jb      loop_suma_1

                push    ebp
                mov     ebp, esp
                push    dword [resultado_suma_1]
                push    largo4 + 2
                push    9
                call    __printf_sum
                leave
                

                mov     [cantidad_sumados], ecx              ; guardo en que parte estoy de la suma


;fin_tarea_1:
;                hlt
;                jmp     fin_tarea_1

fin_tarea_1:
    jmp task1





;********************************************************************************
; Tarea 1 BSS
;********************************************************************************
SECTION 	.task1_bss      nobits

TSS_task_1:
	resb 0x66			;Reservo tamaño para la TSS de 32 bits



;********************************************************************************
; Tarea 1 Data
;********************************************************************************
SECTION 	.task1_data 	

msg4: db 'Suma task 1:',0
largo4 EQU $ - msg4

resultado_suma_1:
                resb 16


cantidad_sumados dd  0

DIGITOS dd  0x1210070
