%define     PORT_A_8042    0x60        ;Puerto A de E/S del 8042
%define     CTRL_PORT_8042 0x64        ;Puerto de Estado del 8042
%define     KEYB_DIS       0xAD        ;Deshabilita teclado con Command Byte
%define     KEYB_EN        0xAE        ;Habilita teclado con Command Byte
%define     READ_OUT_8042  0xD0        ;Copia en 0x60 el estado de OUT
%define     WRITE_OUT_8042 0xD1        ;Escribe en OUT lo almacenado en 0x60

%define X86_CR0_PE      0x00000001 ;/* Protectede mode enable*/
%define X86_CR0_MP      0x00000002 ;/* Monitor coProcessor*/
%define X86_CR0_EM      0x00000004 ;/* Emulation*/
%define X86_CR0_TS      0x00000008 ;/* Task Switched*/
%define X86_CR0_ET      0x00000010 ;/* Extension Type*/
%define X86_CR0_NE      0x00000020 ;/* Numeric Error*/
%define X86_CR0_WP      0x00010000 ;/* Write Protect*/
%define X86_CR0_AM      0x00040000 ;/* Alignment Mask*/
%define X86_CR0_NW      0x20000000 ;/* Not Write-through*/
%define X86_CR0_CD      0x40000000 ;/* Cache Disable*/
%define X86_CR0_PG      0x80000000 ;/* PaGine*/


%define PIC1_COMMAND	0x20
%define PIC1_DATA	0x21
%define PIC2_COMMAND	0xA0
%define PIC2_DATA	0xA1

%define     OFFSET_BACKLINK    	0
%define     OFFSET_ESP0        	4
%define     OFFSET_SS0         	8
%define     OFFSET_ESP1        	12
%define     OFFSET_SS1         	16
%define     OFFSET_ESP2        	20
%define     OFFSET_SS2         	24
%define     OFFSET_CR3         	28
%define     OFFSET_EIP         	32
%define     OFFSET_EFLAGS      	36
%define     OFFSET_EAX         	40
%define     OFFSET_ECX         	44
%define     OFFSET_EDX         	48
%define     OFFSET_EBX         	52
%define     OFFSET_ESP         	56
%define     OFFSET_EBP         	60
%define     OFFSET_ESI         	64
%define     OFFSET_EDI         	68
%define     OFFSET_ES          	72
%define     OFFSET_CS          	76
%define     OFFSET_SS          	80
%define     OFFSET_DS          	84
%define     OFFSET_FS          	88
%define     OFFSET_GS          	92
%define     OFFSET_LDT         	96
%define     OFFSET_T           	100
%define     OFFSET_BITMAP      	102
%define     OFFSET_PRIM_EJEC     104
%define     OFFSET_SIG_CR3	  	108


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

%define     _TD3_HLT    1
%define     _TD3_READ   2
%define     _TD3_WRITE  3