
EXTERN __DATOS_VMA
EXTERN __TABLE_INIT_VMA
EXTERN __printf_sum

GLOBAL timer_control
GLOBAL task1

USE32
section .tarea_1

timer_control:

    inc  dword[__DATOS_VMA]
    cmp  dword[__DATOS_VMA], 50; la interrupcion se activa cada 100 ms -> x lo tanto, tengo que comparar este flag con 50
    JGE  task1
    ret


task1:
    mov  dword[__DATOS_VMA], 0 ; reset de la variable del timer
    push ebp
    mov  ebp, esp
    push __TABLE_INIT_VMA+0x0F  ; mando la posicion donde empieza el buffer de los numeros presionados
    call __printf_sum           ; cada 500ms muestra la suma en pantalla
    leave
    ret

    