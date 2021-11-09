
USE32
GLOBAL Idle_Task_0
;--------------- Task 0 (IDLE) BSS ---------------

SECTION 	.task0_bss 	nobits


;--------------- Task 0 (IDLE) TEXT ---------------

SECTION     .task0_txt

Idle_Task_0:
    hlt
    jmp Idle_Task_0
