%include "inc/procesor-flags.h"

USE32
section .start32

EXTERN  DS_SEL_KERNEL
EXTERN  CS_SEL_KERNEL
EXTERN  D_TSS

EXTERN  __STACK_END_32_VMA
EXTERN  __STACK_END_32_FIS
EXTERN  __STACK_SIZE_32

EXTERN  start32
EXTERN  __NUCLEO_SIZE__
EXTERN  __NUCLEO_FIS
EXTERN  __NUCLEO_VMA
EXTERN  __NUCLEO_LMA

EXTERN  __fast_memcpy_rom
EXTERN  __set_cr3
EXTERN  __set_DTP
EXTERN  __set_PageTable
EXTERN  __DATOS_SIZE__
EXTERN  __DATOS_VMA
EXTERN  __DATOS_LMA

EXTERN  __HANDLERS_SIZE_
EXTERN  __HANDLERS_FIS
EXTERN  __HANDLERS_VMA
EXTERN  __HANDLERS_LMA

EXTERN  __SYS_SIZE__
EXTERN  __SYS_TABLES_FIS
EXTERN  __SYS_TABLES_VMA
EXTERN  __SYS_TABLES_LMA
EXTERN  __TSS_BASICA


EXTERN  __TASK0_TXT_SIZE__
EXTERN  __TASK0_TXT_FIS
EXTERN  __TASK0_TXT_VMA
EXTERN  __TASK0_TXT_LMA
EXTERN  __TASK0_BSS_SIZE__
EXTERN	__TASK0_BSS_FIS
EXTERN	__TASK0_BSS_VMA
EXTERN  __TASK0_BSS_LMA
EXTERN  __TASK0_DAT_SIZE__
EXTERN	__TASK0_DAT_FIS
EXTERN	__TASK0_DAT_VMA
EXTERN	__TASK0_DAT_LMA
EXTERN  __TASK0_DIR_PAG_START
EXTERN  __STACK_TASK0_US_FIS
EXTERN  __STACK_TASK0_US_VMA
EXTERN  __STACK_TASK0_SUP_FIS
EXTERN  __STACK_TASK0_SUP_VMA
EXTERN  __DIR_FIS_CONTEXTO_TAREA0


EXTERN  __TASK1_TXT_SIZE__
EXTERN  __TASK1_TXT_FIS
EXTERN  __TASK1_TXT_VMA
EXTERN  __TASK1_TXT_LMA
EXTERN  __TASK1_BSS_SIZE__
EXTERN	__TASK1_BSS_FIS
EXTERN	__TASK1_BSS_VMA
EXTERN  __TASK1_BSS_LMA
EXTERN  __TASK1_DAT_SIZE__
EXTERN	__TASK1_DAT_FIS
EXTERN	__TASK1_DAT_VMA
EXTERN	__TASK1_DAT_LMA
EXTERN  __TASK1_DIR_PAG_START
EXTERN  __STACK_TASK1_US_FIS
EXTERN  __STACK_TASK1_US_VMA
EXTERN  __STACK_TASK1_SUP_FIS
EXTERN  __STACK_TASK1_SUP_VMA
EXTERN  __DIR_FIS_CONTEXTO_TAREA1

EXTERN  __TASK2_TXT_SIZE__
EXTERN  __TASK2_TXT_FIS
EXTERN  __TASK2_TXT_VMA
EXTERN  __TASK2_TXT_LMA
EXTERN  __TASK2_BSS_SIZE__
EXTERN	__TASK2_BSS_FIS
EXTERN	__TASK2_BSS_VMA
EXTERN  __TASK2_BSS_LMA
EXTERN  __TASK2_DAT_SIZE__
EXTERN	__TASK2_DAT_FIS
EXTERN	__TASK2_DAT_VMA
EXTERN	__TASK2_DAT_LMA
EXTERN  __TASK2_DIR_PAG_START
EXTERN  __STACK_TASK2_US_FIS
EXTERN  __STACK_TASK2_US_VMA
EXTERN  __STACK_TASK2_SUP_FIS
EXTERN  __STACK_TASK2_SUP_VMA
EXTERN  __DIR_FIS_CONTEXTO_TAREA2

EXTERN  _idtr
EXTERN  _gdtr

EXTERN  __PAGTABLE_VMA
EXTERN	__VIDEO_VMA
EXTERN	__TABLA_DIGITO_VMA
EXTERN	__DATOS_VMA
EXTERN	__STACK_START_32_VMA
EXTERN	__STACK_TAREA1_VMA
EXTERN	__INIT_16_VMA
EXTERN	__GDT16_TABLE_VMA
EXTERN	__INIT_32_VMA
EXTERN	__FUNCTIONS_ROM_VMA
EXTERN  __RESET_VMA
EXTERN  __STACK_END_TASK0_SUP_VMA

EXTERN  __PAGTABLE_FIS
EXTERN	__VIDEO_FIS
EXTERN	__TABLA_DIGITO_FIS
EXTERN	__DATOS_FIS
EXTERN	__STACK_START_32_FIS
EXTERN	__STACK_TAREA1_FIS
EXTERN	__INIT_16_FIS
EXTERN	__GDT16_TABLE_FIS
EXTERN	__INIT_32_FIS
EXTERN	__FUNCTIONS_ROM_FIS
EXTERN  __RESET_FIS

EXTERN  __STACK_END_TASK0_USR_VMA
EXTERN  __STACK_END_TASK1_USR_VMA
EXTERN  __STACK_END_TASK2_USR_VMA

EXTERN  __STACK_END_TASK0_SUP_VMA
EXTERN  __STACK_END_TASK1_SUP_VMA
EXTERN  __STACK_END_TASK2_SUP_VMA

EXTERN  __TASK_CONTEXT_VMA
EXTERN  __SIMD_CONTEXT_VMA
EXTERN  __SIMD_CONTEXT1_FIS
EXTERN  __SIMD_CONTEXT2_FIS

EXTERN  TSS_task_0
EXTERN  TSS_task_1
EXTERN  TSS_task_2

EXTERN      __STACK_END_TAREA_VMA
EXTERN      DS_SEL_KERNEL
EXTERN      CS_SEL_KERNEL
EXTERN      DS_SEL_USER
EXTERN      CS_SEL_USER

EXTERN      __TASK2_DIR_PAG_START
EXTERN      Idle_Task_0
EXTERN      task1
EXTERN      task2

EXTERN  __vericar_direccion
EXTERN  halted


GLOBAL start32_launcher

start32_launcher:

    mov     ax, DS_SEL_KERNEL  ; ax tiene el valor del selector de datos, que describe toda la memoria
    mov     ds, ax
    mov     es, ax
    mov     gs, ax
    mov     fs, ax

;Inicializco la pila y cargo stack selector
    mov     ss,ax
    mov     esp, __STACK_END_32_FIS ; recordar el esp siempre al fondo de la pila
    xor     eax, eax

; Limpio la pila, y para eso uso el contador ecx

    mov     ecx, __STACK_SIZE_32 ; Cargo en el contador el tamaño del stack
    .stack_init:
        push    eax             ; "pushea" (pisa) con ceros toda la memoria que compone el stack
        loop    .stack_init     ; Recordar que loop usa rcx, ecx o cx como contador ( decrementa y chekea si esta en cero)

    mov     esp, __STACK_END_32_FIS ; Vuelvo a apuntar con el stack pointer al final

    ;;;;;;;;;;;;;   Copio system tables 32b  (0x00100000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ebp
    mov     ebp, esp
    push    __SYS_SIZE__
    push    __SYS_TABLES_FIS
    push    __SYS_TABLES_LMA
    call    __fast_memcpy_rom
    leave

    cmp eax, 1
    jne halted

    o32 lgdt [_gdtr]
    o32 lidt [_idtr]

    ;;;;;;;;;;;;;   Copio nucleo 32b  (0x00200000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ebp         ; guardo el valor de ebp
    mov     ebp, esp    ; apunto al valor del stack pointer
    ;primero pusheo el ultimo parametro de la funcion hasta el primero
    push    __NUCLEO_SIZE__
    push    __NUCLEO_FIS
    push    __NUCLEO_LMA  
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     halted 

    ;;;;;;;;;;;;;   Copio funciones 32b  (0x00000000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __HANDLERS_SIZE_
    push    __HANDLERS_FIS
    push    __HANDLERS_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     halted 
    ;;;;;;;;;;;;;   Copio datos 32b  (0x00202000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __DATOS_SIZE__
    push    __DATOS_FIS
    push    __DATOS_LMA
    call    __fast_memcpy_rom
    leave

    cmp eax, 1
    jne halted

    ; ----------------------------------------------

    ;--------------   Copio TASK0_text  (0x00300000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK0_TXT_SIZE__
    push    __TASK0_TXT_FIS
    push    __TASK0_TXT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio TASK0_bss  (0x00301000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK0_BSS_SIZE__
    push    __TASK0_BSS_FIS
    push    __TASK0_BSS_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio TASK0_data  (0x00302000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK0_DAT_SIZE__
    push    __TASK0_DAT_FIS
    push    __TASK0_DAT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio task1_text  (0x00310000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK1_TXT_SIZE__
    push    __TASK1_TXT_FIS
    push    __TASK1_TXT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio task1_bss  (0x00311000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK1_BSS_SIZE__
    push    __TASK1_BSS_FIS
    push    __TASK1_BSS_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio task1_data  (0x00312000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK1_DAT_SIZE__
    push    __TASK1_DAT_FIS
    push    __TASK1_DAT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

     ;--------------   Copio task2_text  (0x00320000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK2_TXT_SIZE__
    push    __TASK2_TXT_FIS
    push    __TASK2_TXT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio task2_bss  (0x00321000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK2_BSS_SIZE__
    push    __TASK2_BSS_FIS
    push    __TASK2_BSS_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted

    ;--------------   Copio task2_data  (0x00322000)  -------------------------

    push    ebp
    mov     ebp, esp
    push    __TASK2_DAT_SIZE__
    push    __TASK2_DAT_FIS
    push    __TASK2_DAT_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1
    jne     halted


    ; ------------------  PAGINACIÓN  ----------------------------

    ; ------ SET DE CR3 ---------;
    push    ebp
    mov     ebp, esp
    push    PAG_PWT_SI
    push    PAG_PCD_SI
    push    __PAGTABLE_FIS
    call    __set_cr3
    mov     cr3, eax
    leave

    ; ------ SET DE ENTRY'S ---------;

    ; HANDLERS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __HANDLERS_FIS
    push dword __HANDLERS_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; VIDEO
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __VIDEO_FIS
    push dword __VIDEO_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; System Tables
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __SYS_TABLES_FIS
    push dword __SYS_TABLES_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Nucleo
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __NUCLEO_FIS
    push dword __NUCLEO_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Tabla de digitos
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TABLA_DIGITO_FIS
    push dword __TABLA_DIGITO_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __STACK_START_32_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __STACK_START_32_FIS
    push dword __STACK_START_32_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __INIT_16_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __INIT_16_FIS
    push dword __INIT_16_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __INIT_32_FIS

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __INIT_32_FIS ; ESTO ES IDENTITY MAPPING:
    push dword __INIT_32_VMA ; __INIT_32_FIS = __INIT_32_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave


    ; __FUNCTIONS_ROM_FIS

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __FUNCTIONS_ROM_FIS
    push dword __FUNCTIONS_ROM_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Datos
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DATOS_FIS
    push dword __DATOS_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; data_task1_en_PAGTABLE
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TASK1_DAT_FIS
    push dword __TASK1_DAT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; data_task2_en_PAGTABLE
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TASK2_DAT_FIS
    push dword __TASK2_DAT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; TSS BASICA
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TSS_BASICA
    push dword __TSS_BASICA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave


    ; __TASK_CONTEXT_VMA

    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DIR_FIS_CONTEXTO_TAREA1
    push dword __TASK_CONTEXT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

        ; __TASK_CONTEXT_VMA

    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DIR_FIS_CONTEXTO_TAREA2
    push dword __TASK_CONTEXT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

            ; __TASK_CONTEXT_VMA


    ; --------------------------- TAREA 0 ---------------------------------
    
    ; __TASK0_HANDLERS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __HANDLERS_FIS
    push dword __HANDLERS_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_VIDEO
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __VIDEO_FIS
    push dword __VIDEO_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

     ; __TASK1__INIT_32_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __INIT_32_FIS
    push dword __INIT_32_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_FUNCIONES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __FUNCTIONS_ROM_FIS
    push dword __FUNCTIONS_ROM_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_DATOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DATOS_FIS
    push dword __DATOS_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; Task0_Nucleo
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __NUCLEO_FIS
    push dword __NUCLEO_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_TABLA DIGITOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TABLA_DIGITO_FIS
    push dword __TABLA_DIGITO_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_SYS_TABLES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __SYS_TABLES_FIS
    push dword __SYS_TABLES_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_TXT_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US  -> CAMBIAR A 'USR' PARA EJ 15
    push PAG_US_SUP ; DPTE_US -> CAMBIAR A 'USR' PARA EJ 15
    push dword __TASK0_TXT_FIS
    push dword __TASK0_TXT_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_BSS_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US -> CAMBIAR A 'USR' PARA EJ 15
    push PAG_US_SUP ; DPTE_US -> CAMBIAR A 'USR' PARA EJ 15
    push dword __TASK0_BSS_FIS
    push dword __TASK0_BSS_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK0_DAT_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US -> CAMBIAR A 'USR' PARA EJ 15 
    push PAG_US_SUP ; DPTE_US -> CAMBIAR A 'USR' PARA EJ 15
    push dword __TASK0_DAT_FIS
    push dword __TASK0_DAT_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TAREA0_US_FIS 
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __STACK_TASK0_US_FIS
    push dword __STACK_TASK0_US_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TAREA0_SUP_FIS 
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __STACK_TASK0_SUP_FIS    ; DIR FISICA
    push dword __STACK_TASK0_SUP_VMA    ; DIR LINEAL
    push dword __TASK0_DIR_PAG_START    ; CR3
    call __set_PageTable
    leave

        ; TSS BASICA
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __TSS_BASICA
    push dword __TSS_BASICA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK_CONTEXT_VMA

    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DIR_FIS_CONTEXTO_TAREA0
    push dword __TASK_CONTEXT_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT_VMA (MAPEADO EN CR3 DE TASK0)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT1_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT2_VMA (MAPEADO EN CR3 DE TASK0)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT2_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK0_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TASK1_SUP_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __STACK_TASK1_SUP_FIS
    push dword __STACK_TASK1_SUP_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave



    ; -------------------------- TAREA 1 -------------------------------------

    ; __TASK1_HANDLERS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __HANDLERS_FIS
    push dword __HANDLERS_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_VIDEO
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __VIDEO_FIS
    push dword __VIDEO_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; Task1_Nucleo
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __NUCLEO_FIS
    push dword __NUCLEO_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_FUNCIONES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __FUNCTIONS_ROM_FIS
    push dword __FUNCTIONS_ROM_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_DATOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __DATOS_FIS
    push dword __DATOS_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_TABLA DIGITOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TABLA_DIGITO_FIS
    push dword __TABLA_DIGITO_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_SYS_TABLES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __SYS_TABLES_FIS
    push dword __SYS_TABLES_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave


    ; TSS BASICA
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TSS_BASICA
    push dword __TSS_BASICA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_TXT_FIS

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK1_TXT_FIS  ; 0x00310000
    push dword __TASK1_TXT_VMA  ; 0x01310000
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_BSS_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK1_BSS_FIS
    push dword __TASK1_BSS_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK1_DAT_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK1_DAT_FIS
    push dword __TASK1_DAT_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TASK1_US_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __STACK_TASK1_US_FIS
    push dword __STACK_TASK1_US_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

     ; __TASK1__INIT_32_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __INIT_32_FIS
    push dword __INIT_32_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT_VMA (MAPEADO EN CR3 DE TASK1)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT1_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT2_VMA (MAPEADO EN CR3 DE TASK1)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT2_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK_CONTEXT_VMA

    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DIR_FIS_CONTEXTO_TAREA1
    push dword __TASK_CONTEXT_VMA
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK1_DIR_PAG_START
    push dword __TASK1_DIR_PAG_START
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave


    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword 0x00135000
    push dword 0x00135000
    push dword __TASK1_DIR_PAG_START
    call __set_PageTable
    leave


    ; ----------------------------- TAREA 2 --------------------------------------

    ; __TASK2_HANDLERS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __HANDLERS_FIS
    push dword __HANDLERS_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_VIDEO
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __VIDEO_FIS
    push dword __VIDEO_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_FUNCIONES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __FUNCTIONS_ROM_FIS
    push dword __FUNCTIONS_ROM_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

     ; __TASK2__INIT_32_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __INIT_32_FIS
    push dword __INIT_32_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_DATOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __DATOS_FIS
    push dword __DATOS_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; Task2_Nucleo
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __NUCLEO_FIS
    push dword __NUCLEO_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_TABLA DIGITOS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TABLA_DIGITO_FIS
    push dword __TABLA_DIGITO_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_SYS_TABLES
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __SYS_TABLES_FIS
    push dword __SYS_TABLES_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave


    ; TSS BASICA
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TSS_BASICA
    push dword __TSS_BASICA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_TXT_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK2_TXT_FIS
    push dword __TASK2_TXT_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_BSS_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK2_BSS_FIS
    push dword __TASK2_BSS_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK2_DAT_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK2_DAT_FIS
    push dword __TASK2_DAT_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TASK2_US_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __STACK_TASK2_US_FIS
    push dword __STACK_TASK2_US_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __STACK_TASK2_SUP_FIS
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __STACK_TASK2_SUP_FIS
    push dword __STACK_TASK2_SUP_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __TASK_CONTEXT_VMA

    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_SUP ; DPTE_US
    push dword __DIR_FIS_CONTEXTO_TAREA2
    push dword __TASK_CONTEXT_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT_VMA (MAPEADO EN CR3 DE TASK1)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT1_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    ; __SIMD_CONTEXT_VMA (MAPEADO EN CR3 DE TASK1)
    push ebp
    mov  ebp, esp
    push PAG_RW_W   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_USR ; PTE_US
    push PAG_US_USR ; DPTE_US;
    push dword __SIMD_CONTEXT2_FIS
    push dword __SIMD_CONTEXT_VMA
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword __TASK2_DIR_PAG_START
    push dword __TASK2_DIR_PAG_START
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave

    push ebp
    mov  ebp, esp
    push PAG_RW_R   ; PTE_RW
    push PAG_RW_W   ; DPTE_RW
    push PAG_US_SUP ; PTE_US
    push PAG_US_USR ; DPTE_US
    push dword 0x00145000
    push dword 0x00145000
    push dword __TASK2_DIR_PAG_START
    call __set_PageTable
    leave
; ------------------------------------------------
    ;Activo paginación
    mov eax, cr0
    or  eax, X86_CR0_PG
    mov cr0, eax


    ; --------------------------- SETEO COUNTER --------------------------------
    push ebp     ; Resguardo los resgistros ebp y esp antes de saltar la funcion
    mov ebp, esp ;
    mov cx, 100  ; Cargo en la cx el valor correspondiente para que interrumpa cada 10ms -> 
                 ; 1193 * cx / 1.19318[MHz] = 1000 / cx [int/seg]
    call PIT_Set_Counter0
    leave 
    ;sti

    ; ---------------- INICIALIZO EL CONTROL DE INTERRUPCIONES -----------------
    push ebp     ; Resguardo los resgistros ebp y esp antes de saltar la funcion
    mov ebp, esp 
    call InitPIC
    leave

    ; ------------------- INICIALIZO TSS BASICA --------------------------------
   
    push ebp     ; Resguardo los resgistros ebp y esp antes de saltar la funcion
    mov  ebp, esp 
    call init_TSS_BASICA
    leave

    ; ------------------- INICIALIZO CONTEXTO DE TAREAS---------------------------
    push ebp     ; Resguardo los resgistros ebp y esp antes de saltar la funcion
    mov  ebp, esp
    call Inicializar_Context_Tasks
    leave    
    ; ----------------------------------------------------------------------------
    jmp CS_SEL_KERNEL:start32

    ;-------------- Funcion de salto por error ------------------------------------

    jmp halted


;--------------------------------------------------------------------------------
; CONFIGURACION PIT (TIMER)
;--------------------------------------------------------------------------------


PIT_Set_Counter0:
   push ax
   mov al, 0x34         ; Palabra de control en 8254  
   out 0x43, al         ; En 0x43 está el registro de control.
   mov ax, 1193         ; Los 3 contadores del PIT reciben una señal de clock de 1.19318[MHz] 
   mul cx               ; 1193 * cx / 1.19318[MHz] = 1000 / cx [int/seg]​
   out 0x40, al          ; En 0x40 está el Counter 0.
   mov al, ah
   out 0x40, al
   pop ax
   ret


%define PIC1_COMMAND	0x20
%define PIC1_DATA	    0x21
%define PIC2_COMMAND	0xA0
%define PIC2_DATA	    0xA1

InitPIC:
    ;Inicialización de ambos PICs mediante ICW (Initialization Control Words)

    ;ICW1 = Indicarle a los PIC que estamos inicializándolo.
    mov	al,0x11        	    ;Palabra de inicialización (bit 4=1) indicando que se necesita ICW4 (bit 0=1)
    out PIC1_COMMAND,al   	;Enviar ICW1 al primer PIC
    out PIC2_COMMAND,al		;Enviar ICW1 al segundo PIC

    ;ICW2 = Indicarle a los PIC cuales son los vectores de interrupciones
    mov al,0x20        	    ;El primer PIC va a usar los tipos de interr 0x20-0x27
    out PIC1_DATA,al 		;Enviar ICW2 al primer PIC
    mov al,0x28 		    ;El segundo PIC va a usar los tipos de interr 0x28-0x2F 			
    out PIC2_DATA,al 		;Enviar ICW2 al segundo PIC

    ;ICW3 = Indicarle a los PIC como se conectan como master y slave
    mov al,0x04         ;Decirle al primer PIC que hay un PIC esclavo en IRQ2
    out PIC1_DATA,al	;Enviar ICW3 al primer PIC
    mov al,0x02 		;Decirle al segundo PIC su ID de cascada (2)
    out PIC2_DATA,al 	;Enviar ICW3 al segundo PIC

    ;ICW4 = Información adicional sobre el entorno
    mov al,0x01         ;Poner el PIC en modo 8086
    out PIC1_DATA,al 	;Enviar ICW4 al primer PIC
    out PIC2_DATA,al 	;Enviar ICW4 al segundo PIC

    ; HABILITACION DE INTERRUPCIONES EXTERNAS:
    ; PARA ESTE CASO, TODAS DESHABILITADAS
    ; ( 1 -> DESHABILITADA)
    ; ( 0 -> HABILITADA)
    mov al,11111100b     	;Deshabilito todos los IRQ poniendo bits a 1
    out PIC1_DATA,al    ;Enviar máscara al primer PIC	
    ;STI
    ret


init_TSS_BASICA:
    mov eax, __TSS_BASICA
    ; -> ESP0
    mov [eax + 4], dword(__STACK_END_TASK0_SUP_VMA)
    ; -> SS0
    mov [eax + 8], dword(0x10); El stack segment apunta al descriptor de datos de nivel 00
    ; -> ESP1
    mov [eax + 12], dword(0)
    ; -> SS1
    mov [eax + 16], dword(0)
    ; -> ESP2
    mov [eax + 20], dword(0)
    ; -> SS2
    mov [eax + 24], dword(0)
    ; -> CR3
    mov [eax + 28], dword(__PAGTABLE_VMA)
    ; -> EIP
    mov [eax + 32], dword(start32)
    ; -> EFLAGS
    mov [eax + 36], dword(0x202)
    ; -> EAX
    mov [eax + 40], dword(0)
    ; -> ECX
    mov [eax + 44], dword(0)
    ; -> EDX
    mov [eax + 48], dword(0)
    ; -> EBX
    mov [eax + 52], dword(0)
    ; -> ESP
    mov [eax + 56], dword(0)
    ; -> EBX
    mov [eax + 60], dword(0)
    ; -> ESI
    mov [eax + 64], dword(0)
    ; -> EDI
    mov [eax + 68], dword(0)
    ; -> ES
    mov [eax + 72], dword(DS_SEL_KERNEL)
    ; -> CS
    mov [eax + 76], dword(CS_SEL_KERNEL)
    ; -> SS
    mov [eax + 80], dword(DS_SEL_KERNEL)
    ; -> DS
    mov [eax + 84], dword(DS_SEL_KERNEL)
    ; -> FS
    mov [eax + 88], dword(DS_SEL_KERNEL)
    ; -> GS
    mov [eax + 92], dword(DS_SEL_KERNEL)
    ; -> LDT SEGMENT SELECTOR 
    mov [eax + 96], dword(0)
    ; -> RESERVADO
    mov [eax + 100], dword(0)

    xor     eax, eax
    mov ax, D_TSS
    ltr ax
    ret


    ;--------------------------------------------------------------------------------
    ; Funciones para inicializar los contextos de las tareas
    ;--------------------------------------------------------------------------------
Inicializar_Context_Tasks:
    mov eax, __TASK1_DIR_PAG_START
    mov CR3, eax
    ;task1    
    mov eax,__STACK_END_TASK1_SUP_VMA  		        		;Cargo direccion lineal final de la pila nucleo de la tarea
    mov ecx,__TASK_CONTEXT_VMA  						;Cargo la direccion fisica del contexto de la tarea
    mov dword[ecx + OFFSET_ESP0],eax						;Direccion inicial de la pila de la tarea
    mov dword[ecx + OFFSET_SS0],DS_SEL_KERNEL				;Cargo SS (PL=0)
    mov eax,__STACK_END_TASK1_USR_VMA 			        	;Cargo direccion lineal final de la pila usuario de la tarea
    mov dword[ecx + OFFSET_ESP],eax  						;Direccion inicial de la pila de nivel 3
    mov dword[ecx + OFFSET_SS],DS_SEL_USER 					;
    mov dword[ecx + OFFSET_CR3],__TASK1_DIR_PAG_START		;Valor de CR3 para tarea 1
    mov dword[ecx + OFFSET_EIP],task1						;EIP apunta al inicio del codigo de la tarea 1
    mov dword[ecx + OFFSET_EFLAGS],0x200					;Con unicamente IF activo (interrupciones habilitadas)
    mov dword[ecx + OFFSET_ES],DS_SEL_USER					;ES
    mov dword[ecx + OFFSET_DS],DS_SEL_USER					;DS
    mov dword[ecx + OFFSET_SS],DS_SEL_USER					;SS
    mov dword[ecx + OFFSET_CS],CS_SEL_USER					;CS
    mov dword[ecx + OFFSET_PRIM_EJEC],0						;Es primer ejecucion
    mov dword[ecx + OFFSET_SIG_CR3],__TASK2_DIR_PAG_START	;Proxima tarea: Tarea 2

    mov eax, __TASK2_DIR_PAG_START
    mov CR3, eax
    ;task2
    mov eax,__STACK_END_TASK2_SUP_VMA  			        	;Cargo direccion lineal final de la pila nucleo de la tarea
    mov ecx,__TASK_CONTEXT_VMA 						;Cargo la direccion fisica del contexto de la tarea
    mov dword[ecx + OFFSET_ESP0],eax						;Direccion inicial de la pila de la tarea
    mov dword[ecx + OFFSET_SS0],DS_SEL_KERNEL					;Cargo SS (PL=0)
    mov eax,__STACK_END_TASK2_USR_VMA        				;Cargo direccion lineal final de la pila usuario de la tarea
    mov dword[ecx + OFFSET_ESP],eax  						;Direccion inicial de la pila de nivel 3
    mov dword[ecx + OFFSET_SS],DS_SEL_USER 					;
    mov dword[ecx + OFFSET_CR3],__TASK2_DIR_PAG_START		;Valor de CR3 para tarea 2
    mov dword[ecx + OFFSET_EIP],task2						;EIP apunta al inicio del codigo de la tarea 2
    mov dword[ecx + OFFSET_EFLAGS],0x200					;Con unicamente IF activo (interrupciones habilitadas)
    mov dword[ecx + OFFSET_ES],DS_SEL_USER					;ES
    mov dword[ecx + OFFSET_DS],DS_SEL_USER					;DS
    mov dword[ecx + OFFSET_SS],DS_SEL_USER					;SS
    mov dword[ecx + OFFSET_CS],CS_SEL_USER					;CS
    mov dword[ecx + OFFSET_PRIM_EJEC],0						;Es primer ejecucion
    mov dword[ecx + OFFSET_SIG_CR3],__TASK1_DIR_PAG_START	;Proxima tarea: Tarea 1

    mov eax, __TASK0_DIR_PAG_START
    mov CR3, eax
    ;Idle_Tarea_0
    mov eax,__STACK_END_TASK0_SUP_VMA         				;Cargo direccion lineal final de la pila nucleo de la tarea
    mov ecx,__TASK_CONTEXT_VMA  						;Cargo la direccion fisica del contexto de la tarea
    mov dword[ecx + OFFSET_ESP0],eax						;Direccion inicial de la pila de la tarea
    mov dword[ecx + OFFSET_SS0],DS_SEL_KERNEL				;Cargo SS (PL=0)
    mov dword[ecx + OFFSET_CR3],__TASK0_DIR_PAG_START		;Valor de CR3 para tarea idle
    mov dword[ecx + OFFSET_EIP],Idle_Task_0 				;EIP apunta al inicio del codigo de la tarea idle
    mov dword[ecx + OFFSET_EFLAGS],0x200					;Con unicamente IF activo (interrupciones habilitadas)
    mov dword[ecx + OFFSET_ES],DS_SEL_KERNEL				;ES
    mov dword[ecx + OFFSET_DS],DS_SEL_KERNEL				;DS
    mov dword[ecx + OFFSET_SS],DS_SEL_KERNEL				;SS
    mov dword[ecx + OFFSET_CS],DS_SEL_KERNEL				;CS
    mov dword[ecx + OFFSET_PRIM_EJEC],0						;Es primer ejecucion
    mov dword[ecx + OFFSET_SIG_CR3],__TASK1_DIR_PAG_START	;Proxima tarea: Tarea 1
    ret