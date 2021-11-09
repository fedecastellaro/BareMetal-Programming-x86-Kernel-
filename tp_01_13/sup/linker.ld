	/* TP 1.11*/

	ENTRY (reset)
		/*   Fisica */
		__HANDLERS_FIS		= 0x00000000; 
		__VIDEO_FIS			= 0x000B8000;
		__SYS_TABLES_FIS	= 0x00100000; 
		__PAGTABLE_FIS		= 0x00110000;
		__NUCLEO_FIS		= 0x00200000;
		__TABLA_DIGITO_FIS	= 0x00210000; /*Fin área de guardado de dígitos presionados */
		__DATOS_FIS			= 0x00202000;
		__STACK_START_32_FIS = 0x1ff08000;
		__STACK_END_32_FIS	 = 0x1ff08fff;
		__INIT_16_FIS		= 0xffff0000;
		__INIT_32_FIS		= 0xffffa000;
		__GDT16_TABLE_FIS   = 0xffffd000;
		__FUNCTIONS_ROM_FIS	= 0xffffe000;
		__RESET_FIS			= 0xfffffff0;


		/*   TASK 0   */

		__TASK0_TXT_FIS		= 0x00300000;
		__TASK0_BSS_FIS		= 0x00301000;
		__TASK0_DAT_FIS		= 0x00302000;
		__STACK_TASK0_FIS   = 0x1FFFF000;
		__TASK0_TXT_VMA		= 0x01300000;
		__TASK0_BSS_VMA		= 0x01301000;
		__TASK0_DAT_VMA		= 0x01302000;
		__STACK_TASK0_VMA   = 0x00713000;
		__STACK_END_TAREA_VMA = __STACK_TASK0_VMA + 0x999;
		__TASK0_DIR_PAG_START = __PAGTABLE_VMA; /* CR3 DE TASK0*/

		__TSS_TASK0_VMA 	=  __TASK0_DAT_VMA + 0x100;
		/*   TASK 1   */

		__TASK1_TXT_FIS		= 0x00310000;
		__TASK1_BSS_FIS		= 0x00311000;
		__TASK1_DAT_FIS		= 0x00312000;
		__STACK_TASK1_FIS   = 0x1FFFE000;
		__TASK1_TXT_VMA		= 0x01310000;
		__TASK1_BSS_VMA		= 0x01311000;
		__TASK1_DAT_VMA		= 0x01312000;
		__STACK_TASK1_VMA   = 0x00713000;
		__TASK1_DIR_PAG_START = __PAGTABLE_VMA + 0x10000; /* CR3 DE TASK1*/
												
		__TSS_TASK1_VMA 	=  __TASK1_DAT_VMA + 0x100;


		/*   TASK 2   */

		__TASK2_TXT_FIS		= 0x00320000;
		__TASK2_BSS_FIS		= 0x00321000;
		__TASK2_DAT_FIS		= 0x00322000;
		__STACK_TASK2_FIS   = 0x1FFFD000;
		__TASK2_TXT_VMA		= 0x01320000;
		__TASK2_BSS_VMA		= 0x01321000;
		__TASK2_DAT_VMA		= 0x01322000;
		__STACK_TASK2_VMA   = 0x00713000;
		__TASK2_DIR_PAG_START = __PAGTABLE_VMA + 0x20000; /* CR3 DE TASK2*/

		__TSS_TASK2_VMA 	=  __TASK2_DAT_VMA + 0x100;


		__TSS_BASICA		= 0x04300000;

		/*   VMA */
		__HANDLERS_VMA		= 0x00000000; 
		__VIDEO_VMA			= 0x00010000;
		__SYS_TABLES_VMA	= 0x00100000; 
		__PAGTABLE_VMA		= 0x00110000;
		__NUCLEO_VMA		= 0x01200000;
		__TABLA_DIGITO_VMA	= 0x01210000; /*Fin área de guardado de dígitos presionados */
		__DATOS_VMA			= 0x01202000;
		__PF_NEW_DIR_VMA	 = 0x08000000;
		__STACK_START_32_VMA = 0x1ff08000;
		__STACK_END_32_VMA	 = 0x1ff08fff;
		__INIT_16_VMA		= 0xffff0000;
		__INIT_32_VMA		= 0xffffa000;
		__GDT16_TABLE_VMA   = 0xffffd000;
		__FUNCTIONS_ROM_VMA	= 0xffffe000;
		__RESET_VMA			= 0xfffffff0;

		/*    LMA   */
		__INIT_16_LMA		= 0xffff0000;
		__HANDLERS_LMA		= 0xffff5000;
		__NUCLEO_LMA		= 0xffff6000;
		__DATOS_LMA			= 0xffff7000;

		__TASK0_BSS_LMA		= 0xffff1500;
		__TASK0_DAT_LMA		= 0xffff2000;
		__TASK0_TXT_LMA		= 0xffff9000;

		__TASK1_BSS_LMA		= 0xffff3500;
		__TASK1_DAT_LMA		= 0xffff3000;
		__TASK1_TXT_LMA		= 0xffff2500;

		__TASK2_BSS_LMA		= 0xffff4500;
		__TASK2_DAT_LMA		= 0xffff4000;
		__TASK2_TXT_LMA		= 0xffffc000;

		__GDT16_TABLE_LMA	= 0xffffd000;
		__SYS_TABLES_LMA 	= 0xffffb000;
		__INIT_32_LMA		= 0xffffa000;
		__FUNCTIONS_ROM_LMA	= 0xffffe000;
		__RESET_LMA			= 0xfffffff0;

		__STACK_START_16 	= 0x9000; /* SS=0x9000*/
		__STACK_END_16 		= 0x9fff;

		__STACK_SIZE_32 	= ((__STACK_END_32_FIS - __STACK_START_32_VMA) / 4); /*32b WORD*/
		

	MEMORY
	{
		ram(!r)	: ORIGIN = 0x00000000, LENGTH = 0xffff0000 /* 2^32 (4G) - 2^16 (64K) */
		rom(rx) : ORIGIN = 0xffff0000, LENGTH = 0xffff
	}
	

	SECTIONS
	{
		.nucleo __NUCLEO_VMA :
			AT ( __NUCLEO_LMA )
			{ *(.nucleo); } > ram
		__NUCLEO_SIZE__ = SIZEOF(.nucleo);
		
		.isr __HANDLERS_VMA :
			AT ( __HANDLERS_LMA )
			{ *(.isr); } > ram
		__HANDLERS_SIZE_ = SIZEOF (.isr);

		.sys_tables __SYS_TABLES_VMA :
			AT ( __SYS_TABLES_LMA )
			{ 	*(.sys_table_gdt);
				*(.sys_table_idt); } > ram
		__SYS_SIZE__ = SIZEOF (.sys_tables);

		.datos __DATOS_VMA : 
			AT ( __DATOS_LMA )
			{ *(.datos); } > ram
		__DATOS_SIZE__ = SIZEOF (.datos);

		.task0_txt __TASK0_TXT_VMA : 
			AT ( __TASK0_TXT_LMA )
			{ *(.task0_txt); } > ram
		__TASK0_TXT_SIZE__ = SIZEOF (.task0_txt);

		.task0_bss __TASK0_BSS_VMA : 
			AT ( __TASK0_BSS_LMA )
			{ *(.task0_bss); } > ram
		__TASK0_BSS_SIZE__ = SIZEOF (.task0_bss);
	
		.task0_data __TASK0_DAT_VMA : 
			AT ( __TASK0_DAT_LMA )
			{ *(.task0_data); } > ram
		__TASK0_DAT_SIZE__ = SIZEOF (.task0_data);

		.task1_txt __TASK1_TXT_VMA : 
			AT ( __TASK1_TXT_LMA )
			{ *(.task1_txt); } > ram
		__TASK1_TXT_SIZE__ = SIZEOF (.task1_txt);

		.task1_bss __TASK1_BSS_VMA : 
			AT ( __TASK1_BSS_LMA )
			{ *(.task1_bss); } > ram
		__TASK1_BSS_SIZE__ = SIZEOF (.task1_bss);
	
		.task1_data __TASK1_DAT_VMA : 
			AT ( __TASK1_DAT_LMA )
			{ *(.task1_data); } > ram
		__TASK1_DAT_SIZE__ = SIZEOF (.task1_data);

		.task2_txt __TASK2_TXT_VMA : 
			AT ( __TASK2_TXT_LMA )
			{ *(.task2_txt); } > ram
		__TASK2_TXT_SIZE__ = SIZEOF (.task2_txt);

		.task2_bss __TASK2_BSS_VMA : 
			AT ( __TASK2_BSS_LMA )
			{ *(.task2_bss); } > ram
		__TASK2_BSS_SIZE__ = SIZEOF (.task2_bss);
	
		.task2_data __TASK2_DAT_VMA : 
			AT ( __TASK2_DAT_LMA )
			{ *(.task2_data); } > ram
		__TASK2_DAT_SIZE__ = SIZEOF (.task2_data);

		.sys_table_gdt16 __GDT16_TABLE_VMA :
			AT ( __GDT16_TABLE_LMA )
			{ 	*(.sys_table_gdt16); } > rom

		.codigo_init16 __INIT_16_VMA :
			AT ( __INIT_16_LMA )
			{ *(.ROM_init);
			  *(.video); } > rom
		
		.codigo_init32 __INIT_32_VMA :
			AT ( __INIT_32_LMA )
			{ *(.start32); } > rom
		
		.functions_rom __FUNCTIONS_ROM_VMA :
			AT ( __FUNCTIONS_ROM_LMA )
			{ * (.functions_rom); } > rom

		.codigo_reset __RESET_VMA :
			AT ( __RESET_LMA )
			{ * (.resetVector); } > rom
			
		.fill_rom :
			{ FILL(0x90);
				. = ORIGIN(rom) + LENGTH(rom) - 1;
				BYTE(0x90);			
			} > rom
		
		.end_rom 0xffffffff :
			AT ( 0xffffffff )
			{
				BYTE(0x90);
			}
	}
