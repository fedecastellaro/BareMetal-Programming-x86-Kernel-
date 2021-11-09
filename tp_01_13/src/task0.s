
USE32
GLOBAL Idle_Task_0
GLOBAL TSS_task_0
;--------------- Task 0 (IDLE) BSS ---------------

SECTION 	.task0_bss 	nobits

TSS_task_0:
	resb 0x66			;Reservo tamaño para la TSS de 32 bits

;--------------- Task 0 (IDLE) TEXT ---------------

SECTION     .task0_txt

Idle_Task_0:
    hlt
    jmp Idle_Task_0
