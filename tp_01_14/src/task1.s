
EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla

GLOBAL task1
GLOBAL TSS_task_1
GLOBAL largo4
GLOBAL msg4
GLOBAL registros_SIMD_tarea_1


%define _START_TABLA_DIGITO 0x1210070

USE32
section .task1_txt


task1:
init_tarea_1:
                xor     ecx, ecx
                pxor    mm0, mm0
                pxor    mm1, mm1
                mov     ecx, [cantidad_sumados]              ; retomo desde donde me quede en la suma (numero_actual_1)
                mov     eax, [Cant_digitos_tabla]
                cmp     [Cant_digitos_tabla], ecx
                jne     loop_suma_1
                jmp     fin_tarea_1

loop_suma_1:
                movq    mm0, qword[resultado_suma_1]              ; guardo resultado
                movq    mm1, qword[_START_TABLA_DIGITO+ecx*8]            ; nuevo numero
                paddq   mm0, mm1
                movq    qword[resultado_suma_1], mm0              ; guardo resultado

                inc     ecx
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

fin_tarea_1:
                hlt
                jmp     init_tarea_1

;fin_tarea_1:
;    jmp task1



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

ALIGN 16
registros_SIMD_tarea_1:
                times 512 db 0x00