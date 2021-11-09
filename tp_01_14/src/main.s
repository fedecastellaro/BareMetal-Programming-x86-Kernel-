; https://stackoverflow.com/questions/1856320/purpose-of-esi-edi-registers
; https://www.tutorialspoint.com/assembly_programming/assembly_registers.htm
; http://www.eecg.toronto.edu/~amza/www.mindsec.com/files/x86regs.html
; http://www.unixwiz.net/techtips/x86-jumps.html
; https://wiki.osdev.org/PS/2_Keyboard

;--------------------------------------------------------------------------------
; Simbolos externos
;--------------------------------------------------------------------------------
GLOBAL		start32
GLOBAL      main
GLOBAL      indice
GLOBAL      msg3


GLOBAL 	Cant_digitos_tabla
GLOBAL 	IndiceTeclaLoop
GLOBAL 	IndiceTeclaInt
GLOBAL 	IndiceTablaDigitos
GLOBAL 	CantDigitos
GLOBAL 	CantPalabras
GLOBAL 	BufferTablaTeclado
GLOBAL 	IndiceBufferTeclado
GLOBAL 	TareaActual
GLOBAL 	TareaProx
GLOBAL 	ContTarea1
GLOBAL 	ContTarea2
GLOBAL  FlagTimer
GLOBAL  Suma_1
GLOBAL  SumaPrint_1
GLOBAL 	Suma_2
GLOBAL 	SumaPrint_2
GLOBAL 	CantPag_PF
GLOBAL  ultima_tarea_xmm
;--------------------------------------------------------------------------------
; Macros
;--------------------------------------------------------------------------------

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60

%define 	TECLA_STATUS   	0x64
%define 	TECLA_BUFFER	0x60
%define 	TECLA_Y			0x15
%define 	TECLA_U			0x16
%define 	TECLA_I			0x17
%define 	TECLA_O			0x18
%define 	TECLA_F			0x21
%define     FILA_0          0
%define     FILA_1          1
%define     FILA_2          2
%define     FILA_4          4
%define     FILA_9          9
%define     FILA_10         10

%define     COLUMNA_0       0

EXTERN      __printf_sum
EXTERN      __my_printf

EXTERN      __TABLE_INIT_VMA
EXTERN      _acumular_en_tabla_aux
EXTERN      _acumular_en_tabla_fin
EXTERN      _acumular_en_buffer

EXTERN      __DATOS_FIS
EXTERN      __TASK0_DIR_PAG_START
EXTERN      __TASK1_DIR_PAG_START
EXTERN      __TASK2_DIR_PAG_START
EXTERN      Idle_Task_0
EXTERN      task1
EXTERN      task2
EXTERN      largo4
EXTERN      msg4
EXTERN      largo5
EXTERN      msg5

EXTERN      TSS_task_0
EXTERN      TSS_task_1
EXTERN      TSS_task_2
EXTERN      DS_SEL
EXTERN      __STACK_END_TAREA_VMA
EXTERN      CS_SEL_32


USE32


;********************************************************************************
; Datos
;********************************************************************************
SECTION 	.datos		

msg:  DB 'Ej 1.13 - Al presionar ENTER se muestra en pantalla la suma de los numeros',0
largo EQU $ - msg

msg2: db 'Se estan ejecutando dos tareas, cada una mostrando la suma de los numeros de la tabla de digitos',0
largo2 EQU $ - msg2

msg3: db 'Suma total de los numeros(ingresados en el orden correcto):',0
largo3 EQU $ - msg3

Cant_digitos_tabla:
	resb 0x1 			;Reservo 1 byte

IndiceTeclaLoop:
	resb 0x1			;Reservo 1 byte

IndiceTablaDigitos:
	resb 0x1			;Reservo 1 byte

CantDigitos:
	resb 0x1 			;Reservo 1 byte

CantPalabras:	
	resb 0x1 			;Reservo 1 byte

TareaActual:
	resb 0x1 			;Tarea que se esta ejecutando actualmente

TareaProx:
	resb 0x1 			;Tarea que se esta ejecutando actualmente

ContTarea1: 	
	resb 0x2			;Reservo 2 byte

ContTarea2: 	
	resb 0x2			;Reservo 2 byte

ultima_tarea_xmm:
                dd      0x00000000                      ; guardo el cr3

indice  dd  0



;********************************************************************************
; Nucleo
;********************************************************************************
SECTION     .nucleo

start32:
    ;Muestro presentación del ejercicio en pantalla
    push ebp
    mov  ebp, esp
    push largo
    push msg
    push COLUMNA_0
    push FILA_0
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo2
    push msg2
    push COLUMNA_0
    push FILA_1
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo3
    push msg3
    push COLUMNA_0
    push FILA_4
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo4
    push msg4
    push COLUMNA_0
    push FILA_9
    call __my_printf
    leave

    push ebp
    mov  ebp, esp
    push largo5
    push msg5
    push COLUMNA_0
    push FILA_10
    call __my_printf
    leave

Config_Tarea_0:
    mov eax,__TASK0_DIR_PAG_START
    mov cr3,eax
    mov esp,__STACK_END_TAREA_VMA
    
Inicializar_TSS_task_0:
    push Idle_Task_0
    push __TASK0_DIR_PAG_START
    call Inicializar_Contexto_Tarea_0
    add esp,8

Config_Tarea_1:
    mov eax,__TASK1_DIR_PAG_START
    mov cr3,eax
    mov esp,__STACK_END_TAREA_VMA

Inicializar_TSS_task_1:
    push task1
    push __TASK1_DIR_PAG_START
    call Inicializar_Contexto_Tarea_1
    add esp,8

Config_Tarea_2:
    mov eax,__TASK2_DIR_PAG_START
    mov cr3,eax
    mov esp,__STACK_END_TAREA_VMA

Inicializar_TSS_task_2:
    push task2
    push __TASK2_DIR_PAG_START
    call Inicializar_Contexto_Tarea_2
    add esp,8

    ;Empiezo en Idle (Tarea 0)
    mov eax,__TASK0_DIR_PAG_START 
    mov cr3,eax

    xor eax,eax                 ;Limpio los registros de uso general
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    xor edi,edi
    xor esi,esi
    xor ebp,ebp
    
    sti                         ;Habilito interrupciones

    jmp Idle_Task_0            ;Salto a Idle_Tarea_0


;--------------------------------------------------------------------------------
; Funciones para inicializar el contexto de la tarea
;--------------------------------------------------------------------------------
    ;STACK
    ;   x   dir de retorno
    ;   x+4 Dir de tabla de directorio      
    ;   x+8 Dir de inicio de la tarea
    ;Las TSS siempre se encontraran en la misma dir lineal (al inicio de la seccion .data) 
Inicializar_Contexto_Tarea_0:
    mov eax,[esp+4]
    mov [TSS_task_0 + 0x1C],eax  ;cr3
    mov eax,[esp+8]
    mov [TSS_task_0 + 0x20],eax  ;EIP
    mov DWORD [TSS_task_0 + 0x04],__STACK_END_TAREA_VMA ;esp0
    mov WORD [TSS_task_0 + 0x08],DS_SEL    ;ss lvl0
    mov DWORD [TSS_task_0 + 0x38],__STACK_END_TAREA_VMA ;esp
    mov WORD [TSS_task_0 + 0x4c],CS_SEL_32 ;cs
    mov WORD [TSS_task_0 + 0x48],DS_SEL    ;es
    mov WORD [TSS_task_0 + 0x50],DS_SEL    ;ss
    mov WORD [TSS_task_0 + 0x54],DS_SEL    ;ds
    mov WORD [TSS_task_0 + 0x58],DS_SEL    ;fs
    mov WORD [TSS_task_0 + 0x5E],DS_SEL    ;gs
    ret

Inicializar_Contexto_Tarea_1:
    mov eax,[esp+4]
    mov [TSS_task_1 + 0x1C],eax  ;cr3
    mov eax,[esp+8]
    mov [TSS_task_1 + 0x20],eax  ;EIP
    mov DWORD [TSS_task_1 + 0x04],__STACK_END_TAREA_VMA ;esp0
    mov WORD [TSS_task_1 + 0x08],DS_SEL    ;ss lvl0
    mov DWORD [TSS_task_1 + 0x38],__STACK_END_TAREA_VMA ;esp
    mov WORD [TSS_task_1 + 0x4c],CS_SEL_32 ;cs
    mov WORD [TSS_task_1 + 0x48],DS_SEL    ;es
    mov WORD [TSS_task_1 + 0x50],DS_SEL    ;ss
    mov WORD [TSS_task_1 + 0x54],DS_SEL    ;ds
    mov WORD [TSS_task_1 + 0x58],DS_SEL    ;fs
    mov WORD [TSS_task_1 + 0x5E],DS_SEL    ;gs
    ret

Inicializar_Contexto_Tarea_2:
    mov eax,[esp+4]
    mov [TSS_task_2 + 0x1C],eax  ;cr3
    mov eax,[esp+8]
    mov [TSS_task_2 + 0x20],eax  ;EIP
    mov DWORD [TSS_task_2 + 0x04],__STACK_END_TAREA_VMA ;esp0
    mov WORD [TSS_task_2 + 0x08],DS_SEL    ;ss lvl0
    mov DWORD [TSS_task_2 + 0x38],__STACK_END_TAREA_VMA ;esp
    mov WORD [TSS_task_2 + 0x4c],CS_SEL_32 ;cs
    mov WORD [TSS_task_2 + 0x48],DS_SEL    ;es
    mov WORD [TSS_task_2 + 0x50],DS_SEL    ;ss
    mov WORD [TSS_task_2 + 0x54],DS_SEL    ;ds
    mov WORD [TSS_task_2 + 0x58],DS_SEL    ;fs
    mov WORD [TSS_task_2 + 0x5E],DS_SEL    ;gs
    ret

