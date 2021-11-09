USE16 ; directiva para el compilador
section .resetVector

EXTERN start16
GLOBAL reset
GLOBAL halted

reset:
    cld ; clear direction 
    jmp start16

halted:
    hlt
    jmp halted
end:
