USE16 ; directiva para el compilador
section .resetVector

EXTERN start16
GLOBAL reset

reset:
    cli ; apago las interrupciones para que no salte ninguna excepcion ( todavia no tenemos idt! )
    cld ; clear direction 
    jmp start16
    halted:
        hlt
        jmp halted
    end:
