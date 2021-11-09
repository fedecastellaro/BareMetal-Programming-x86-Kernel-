%include "inc/procesor-flags.h"

USE32
section .start32

EXTERN  DS_SEL
EXTERN  CS_SEL_32

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

EXTERN  __TASK1_SIZE__
EXTERN  __TASK1_TXT_FIS
EXTERN  __TASK1_TXT_VMA
EXTERN  __TASK1_TXT_LMA

EXTERN  _idtr
EXTERN  _gdtr

EXTERN  __PAGTABLE_VMA
EXTERN	__VIDEO_VMA
EXTERN	__TABLE_INIT_VMA
EXTERN	__DATOS_VMA
EXTERN	__TASK1_BSS_VMA
EXTERN	__TASK1_DAT_VMA
EXTERN	__STACK_START_32_VMA
EXTERN	__STACK_TAREA1_VMA
EXTERN	__INIT_16_VMA
EXTERN	__GDT16_TABLE_VMA
EXTERN	__INIT_32_VMA
EXTERN	__FUNCTIONS_ROM_VMA
EXTERN  __RESET_VMA

EXTERN  __PAGTABLE_FIS
EXTERN	__VIDEO_FIS
EXTERN	__TABLE_INIT_FIS
EXTERN	__DATOS_FIS
EXTERN	__TASK1_BSS_FIS
EXTERN	__TASK1_DAT_FIS
EXTERN	__STACK_START_32_FIS
EXTERN	__STACK_TAREA1_FIS
EXTERN	__INIT_16_FIS
EXTERN	__GDT16_TABLE_FIS
EXTERN	__INIT_32_FIS
EXTERN	__FUNCTIONS_ROM_FIS
EXTERN  __RESET_FIS

EXTERN  halted


%define     PAG_PWT_SI      1
%define     PAG_PWT_NO      0
%define     PAG_PCD_SI      1
%define     PAG_PCD_NO      0
%define     PAG_P_SI        1
%define     PAG_P_NO        0
%define     PAG_RW_W        1
%define     PAG_RW_R        0
%define     PAG_US_USR      1        
%define     PAG_US_SUP      0        
%define     PAG_A_SI        1
%define     PAG_A_NO        0
%define     PAG_PS_4M       1
%define     PAG_PS_4K       0
%define     PAG_D_SI        1
%define     PAG_D_NO        0
%define     PAG_PAT_SI      1
%define     PAG_PAT_NO      0
%define     PAG_G_SI        1
%define     PAG_G_NO        0


GLOBAL start32_launcher

start32_launcher:

    mov     ax, DS_SEL  ; ax tiene el valor del selector de datos, que describe toda la memoria
    mov     ds, ax
    mov     es, ax
    mov     gs, ax
    mov     fs, ax

;Inicializco la pila y cargo stack selector
    mov     ss,ax
    mov     esp, __STACK_END_32_FIS ; recordar el esp siempre al fondo de la pila
    xor     eax, eax

; Limpio la pila, y para eso uso el contador ecx

    mov ecx, __STACK_SIZE_32 ; Cargo en el contador el tamaño del stack
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

    ;;;;;;;;;;;;;   Copio tarea1_ datos  (0x00300000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __TASK1_SIZE__
    push    __TASK1_TXT_FIS
    push    __TASK1_TXT_LMA
    call    __fast_memcpy_rom
    leave

    cmp eax, 1
    jne halted

    ; ------------------ SETEO COUNTER ----------------------------
    push ebp
    mov ebp, esp
    mov cx, 100
    call PIT_Set_Counter0
    leave 
    sti

    ; ------------------  PAGINACIÓN  ----------------------------

    ; ------ SET DE CR3 ---------;
    push ebp
    mov  ebp, esp
    push PAG_PWT_SI
    push PAG_PCD_SI
    push __PAGTABLE_FIS
    call __set_cr3
    mov  cr3, eax
    leave

    ; ------ SET DE ENTRY'S ---------;

    ; HANDLERS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __HANDLERS_FIS
    push dword __HANDLERS_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; VIDEO
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __VIDEO_FIS
    push dword __VIDEO_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; System Tables
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __SYS_TABLES_FIS
    push dword __SYS_TABLES_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Nucleo
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __NUCLEO_FIS
    push dword __NUCLEO_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Tabla de digitos
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __TABLE_INIT_FIS
    push dword __TABLE_INIT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; Datos
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __DATOS_FIS
    push dword __DATOS_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __TASK1_TXT_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __TASK1_TXT_FIS
    push dword __TASK1_TXT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __TASK1_BSS_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __TASK1_BSS_FIS
    push dword __TASK1_BSS_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __TASK1_DAT_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __TASK1_DAT_FIS
    push dword __TASK1_DAT_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __STACK_TAREA1_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __STACK_TAREA1_FIS
    push dword __STACK_TAREA1_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __STACK_START_32_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __STACK_START_32_FIS
    push dword __STACK_START_32_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __INIT_16_FIS
    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __INIT_16_FIS
    push dword __INIT_16_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ; __INIT_32_FIS

    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __INIT_32_FIS
    push dword __INIT_32_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave


    ; __INIT_32_FIS

    push ebp
    mov  ebp, esp
    push PAG_PS_4K
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword __FUNCTIONS_ROM_FIS
    push dword __FUNCTIONS_ROM_VMA
    push dword __PAGTABLE_FIS
    call __set_PageTable
    leave

    ;Activo paginación
    mov eax, cr0
    or  eax, X86_CR0_PG
    mov cr0, eax
    
    ; ----------------------------------------------

    jmp CS_SEL_32:start32
 

 ;-------------- Funcion de salto por error ------------------------------------

    jmp halted


;--------------------------------------------------------------------------------
; IDT INICIALIZACION
;--------------------------------------------------------------------------------


PIT_Set_Counter0:
   push ax
   mov al, 00110100b
   out 43h, al             ;En 43h está el registro de control.
   mov ax, 1193            ;Los 3 contadores del PIT reciben una señal de clock de 1.19318[MHz] 
   mul cx                  ;1193 * cx / 1.19318[MHz] = 1000 / cx [int/seg]​
   out 40h, al             ; En 40h está el Counter 0.
   mov al, ah
   out 40h, al
   pop ax
   ret
