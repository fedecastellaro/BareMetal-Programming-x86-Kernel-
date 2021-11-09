USE16 ; directiva para el compilador
section .resetVector

EXTERN start16
GLOBAL reset
GLOBAL halted

reset:
    cld ; clear direction
    cli
    jmp start16

halted:
    hlt
    jmp halted
end:
