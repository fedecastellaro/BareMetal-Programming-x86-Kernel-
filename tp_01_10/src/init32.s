%include "inc/procesor-flags.h"

USE32
section .start32

EXTERN  DS_SEL
EXTERN  CS_SEL_32

EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32

EXTERN  start32
EXTERN  __NUCLEO_SIZE__
EXTERN  __NUCLEO_VMA
EXTERN  __NUCLEO_LMA

EXTERN  __fast_memcpy_rom
EXTERN  __set_cr3
EXTERN  __set_DTP
EXTERN  __set_TP_entry
EXTERN  __DATOS_SIZE__
EXTERN  __DATOS_VMA
EXTERN  __DATOS_LMA

EXTERN  __HANDLERS_SIZE_
EXTERN  __HANDLERS_VMA
EXTERN  __HANDLERS_LMA

EXTERN  __SYS_SIZE__
EXTERN  __SYS_TABLES_VMA
EXTERN  __SYS_TABLES_LMA

EXTERN  __TASK1_SIZE__
EXTERN  __TASK1_TXT_VMA
EXTERN  __TASK1_TXT_LMA

EXTERN  _idtr
EXTERN  _gdtr

EXTERN  __PAGTABLE_VMA
EXTERN	__VIDEO_VMA
EXTERN	__TABLE_INIT
EXTERN	__DATOS_VMA
EXTERN	__TASK1_BSS_VMA
EXTERN	__TASK1_DAT_VMA
EXTERN	__STACK_START_32
EXTERN	__STACK_TAREA1
EXTERN	__INIT_16_VMA
EXTERN	__GDT16_TABLE_VMA
EXTERN	__INIT_32_VMA
EXTERN	__FUNCTIONS_ROM_VMA
EXTERN  __RESET_VMA

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
;En este punto ya me encuentro en modo protegido!

start32_launcher:

    mov     ax, DS_SEL  ; ax tiene el valor del selector de datos, que describe toda la memoria
    mov     ds, ax
    mov     es, ax
    mov     gs, ax
    mov     fs, ax

;Inicializco la pila y cargo stack selector
    mov     ss,ax
    mov     esp, __STACK_END_32 ; recordar el esp siempre al fondo de la pila
    xor     eax, eax

; Limpio la pila, y para eso uso el contador ecx

    mov ecx, __STACK_SIZE_32 ; Cargo en el contador el tamaño del stack
    .stack_init:
        push    eax             ; "pushea" (pisa) con ceros toda la memoria que compone el stack
        loop    .stack_init     ; Recordar que loop usa rcx, ecx o cx como contador ( decrementa y chekea si esta en cero)
    mov     esp, __STACK_END_32 ; Vuelvo a apuntar con el stack pointer al final

    ;;;;;;;;;;;;;   Copio system tables 32b  (0x00100000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ebp
    mov     ebp, esp
    push    __SYS_SIZE__
    push    __SYS_TABLES_VMA
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
    push    __NUCLEO_VMA
    push    __NUCLEO_LMA  
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     halted 

    ;;;;;;;;;;;;;   Copio funciones 32b  (0x00000000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __HANDLERS_SIZE_
    push    __HANDLERS_VMA
    push    __HANDLERS_LMA
    call    __fast_memcpy_rom
    leave

    cmp     eax, 1 ; Si pudo copiar correctamente, memcopy devuelve un 1 
    jne     halted 
    ;;;;;;;;;;;;;   Copio datos 32b  (0x00202000)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    push    ebp
    mov     ebp, esp
    push    __DATOS_SIZE__
    push    __DATOS_VMA
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
    push    __TASK1_TXT_VMA
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
    ;SETEO EL CR3

    push    ebp
    mov     ebp, esp
    push    PAG_PWT_SI
    push    PAG_PCD_SI
    push    dword(__PAGTABLE_VMA)
    call    __set_cr3
    mov     CR3, eax
    leave

    ; ----------------------------------------------

    ;Entry del directorio para ISR/VIDEO/nucleo/tabla de digi... todo lo que esta por abajo de los 0x003

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_PS_4K
    push    dword(__PAGTABLE_VMA+0x1000)
    push    0x00
    push    dword(__PAGTABLE_VMA)
    call    __set_DTP
    leave

    ; ----------------------------------------------

    ;Entry del directorio para PILA (0x1FF08000)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_PS_4K
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x7F)
    push    0x7F
    push    dword(__PAGTABLE_VMA)
    call    __set_DTP
    leave

    ; ----------------------------------------------

    ;Entry del directorio para la ROM (Todo aquello que se encuentre abajo de 0xffff0000)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_PS_4K
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x3ff) 
    push    0x3FF
    push    dword(__PAGTABLE_VMA)
    call    __set_DTP
    leave

    ; --------------------------------------------------
    ; -------------- TABLAS DE PAGINA ------------------
    ;---------------------------------------------------

    ;---------------------------------------------------

   ;Entry de la PT3F0 (para INIT_16_VMA)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__INIT_16_VMA) 
    push    0x3F0
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x3FF)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PT3FF (para __FUNCTIONS_ROM_VMA)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__FUNCTIONS_ROM_VMA) 
    push    0x3FF
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x3FF)
    call    __set_TP_entry
    leave


   ;---------------------------------------------------

   ;Entry de la PT3FA (para __INIT_32_VMA)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__INIT_32_VMA) 
    push    0x3FA
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x3FF)
    call    __set_TP_entry
    leave

   ;---------------------------------------------------

   ;Entry de la PT3FD (para __GDT16_TABLE_VMA)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__GDT16_TABLE_VMA) 
    push    0x3FD
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x3FF)
    call    __set_TP_entry
    leave

   ;Entry de la PT0 (para la ISR)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__HANDLERS_VMA) 
    push    0x00
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PTB8 (para VIDEO)

    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA) 
    push 0x0b8 ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave

    ;; Entry de la PT1 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x1) 
    push 0x0b9 ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT2 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x2) 
    push 0x0ba ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT3 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x3) 
    push 0x0bb ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT4 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x4) 
    push 0x0bc ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT6 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x6) 
    push 0x0bd ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT7 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x7) 
    push 0x0be ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;; Entry de la PT7 para Video
    push ebp
    mov  ebp, esp
    push PAG_P_SI
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A_NO
    push PAG_D_NO
    push PAG_PAT_NO
    push PAG_G_SI
    push dword (__VIDEO_VMA+0x1000*0x7) 
    push 0x0bf ;Es el número de Entry
    push dword (__PAGTABLE_VMA+0x1000)
    call __set_TP_entry
    leave


    ;---------------------------------------------------

   ;Entry de la PT100 (para SYSTEM TABLES)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__SYS_TABLES_VMA) 
    push    0x100
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave
    ;---------------------------------------------------

   ;Entry de la PT110 (para las Paginas de tabla)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__PAGTABLE_VMA) 
    push    0x110
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave
    ;---------------------------------------------------

   ;Entry de la PT200 (para el NUCLE0)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__NUCLEO_VMA) 
    push    0x200
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PT210 (para el TABLE_INIT)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__TABLE_INIT) 
    push    0x210
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave
    ;---------------------------------------------------

   ;Entry de la PT202 (para VARIABLES)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__DATOS_VMA) 
    push    0x202
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PT300 (para TEXTO TASK1)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__TASK1_TXT_VMA) 
    push    0x300
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave
    ;---------------------------------------------------

   ;Entry de la PT301 (para BSS TASK1)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__TASK1_BSS_VMA) 
    push    0x301
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PT302 (para DATOS TASK1)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__TASK1_DAT_VMA) 
    push    0x302
    push    dword(__PAGTABLE_VMA+0x1000)
    call    __set_TP_entry
    leave

    ;---------------------------------------------------

   ;Entry de la PT308 (para STACK)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__STACK_START_32) 
    push    0x308
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x7F)
    call    __set_TP_entry
    leave
    ;---------------------------------------------------

   ;Entry de la PT3FF (para STACK TASK1)

    push    ebp
    mov     ebp, esp
    push    PAG_P_SI
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A_NO
    push    PAG_D_NO
    push    PAG_PAT_NO
    push    PAG_G_SI
    push    dword(__STACK_TAREA1) 
    push    0x3FF
    push    dword(__PAGTABLE_VMA+0x1000+0x1000*0x7F)
    call    __set_TP_entry
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
