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