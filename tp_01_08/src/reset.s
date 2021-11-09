USE16 ; directiva para el compilador
section .resetVector

EXTERN start16
GLOBAL reset

reset:
    cld ; clear direction 
    jmp start16
    ;ALIGN 16
    halted:
        hlt
        jmp halted
    end:
