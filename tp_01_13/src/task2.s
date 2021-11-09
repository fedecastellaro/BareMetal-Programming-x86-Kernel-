

EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla
GLOBAL TSS_task_2
GLOBAL task2
GLOBAL largo5
GLOBAL msg5

USE32
section .task2_txt

task2:

init_tarea_2:
                xor     ecx, ecx
                mov     ecx, [cantidad_sumados]              ; retomo desde donde me quede en la suma (numero_actual_1)
                mov     eax, [Cant_digitos_tabla]
                cmp     [Cant_digitos_tabla], ecx
                jne     sumar_numeros_2
                jmp     fin_tarea_2


sumar_numeros_2:
                clc                                     ; limpio carry

loop_suma_2:

                mov     eax, [resultado_suma_2+4]       ; parte baja del resultado anterior (resultado_suma_2)
                mov     ebx, [0x1210070+ecx*8+4]          ; parte baja del nuevo numero
                adc     eax, ebx
                mov     [resultado_suma_2+4], eax

                mov     eax, [resultado_suma_2]              ; parte alta del resultado anterior
                mov     ebx, [0x1210070+ecx*8]            ; parte alta del nuevo numero
                adc     eax, ebx
                mov     [resultado_suma_2], eax

                inc     ecx
                inc     edi
                cmp     ecx, [Cant_digitos_tabla]
                jb      loop_suma_2

                push    ebp
                mov     ebp, esp
                push    dword [resultado_suma_2]
                push    largo5 + 2
                push    10
                call    __printf_sum
                leave
                

                mov     [cantidad_sumados], ecx              ; guardo en que parte estoy de la suma


;fin_tarea_2:
;                hlt
;                jmp     fin_tarea_2

;fin_tarea_2:
;    jmp task2


;********************************************************************************
; Tarea 2 BSS
;********************************************************************************
SECTION 	.task2_bss 	nobits

TSS_task_2:
	resb 0x66			;Reservo tamaño para la TSS de 32 bits


;********************************************************************************
; Tarea 2 Data
;********************************************************************************
SECTION 	.task2_data 	

msg5: db 'Suma task 2:',0
largo5 EQU $ - msg5

resultado_suma_2:
                resb 16

cantidad_sumados dd  0
