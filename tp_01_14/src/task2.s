

EXTERN __DATOS_VMA
EXTERN __TABLA_DIGITO_VMA
EXTERN __printf_sum
EXTERN Cant_digitos_tabla
GLOBAL TSS_task_2
GLOBAL task2
GLOBAL largo5
GLOBAL msg5
GLOBAL registros_SIMD_tarea_2

%define _START_TABLA_DIGITO 0x1210070


USE32
section .task2_txt

task2:

init_tarea_2:
                xor     ecx, ecx
                pxor    mm0, mm0
                pxor    mm1, mm1
                mov     ecx, [cantidad_sumados]              ; retomo desde donde me quede en la suma (numero_actual_1)
                mov     eax, [Cant_digitos_tabla]
                cmp     [Cant_digitos_tabla], ecx
                jne     loop_suma_2
                jmp     fin_tarea_2

loop_suma_2:
                movq      mm0, qword[resultado_suma_2]           ; guardo resultado
                movq      mm1, qword[_START_TABLA_DIGITO+ecx*8]            ; nuevo numero
                paddusw   mm0, mm1
                movq      qword[resultado_suma_2], mm0              ; guardo resultado

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


fin_tarea_2:
                hlt
                jmp     task2



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

ALIGN 16
registros_SIMD_tarea_2:
                times 512 db 0x00