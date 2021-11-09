	/* TP 1.8*/

	ENTRY (reset)
		/*   VMA */
		__TECLADO_FUNC_VMA	= 0x00000000; /* Función de Para Teclado con Int*/
		__SYS_TABLES_VMA	= 0x00100000; /* Nos aprovechamos del Shadow*/
		__NUCLEO_VMA		= 0x00200000;
		__DATOS_VMA			= 0x00202000;
		__TAREA1_VMA		= 0x00300000;	

		__INIT_16_VMA		= 0xffff0000;
		__GDT16_TABLE_VMA   = 0xffffd000;
		__INIT_32_VMA		= 0xfffff800;
		__FUNCTIONS_ROM_VMA	= 0xfffffa00;
		__RESET_VMA			= 0xfffffff0;

		__VARIABLES			= 0x00202000;

		/*    LMA   */
		__INIT_16_LMA		= 0xffff0000;
		__SYS_TABLES_LMA 	= 0xffffe000;
		__TECLADO_FUNC_LMA	= 0xffff5000;
		__NUCLEO_LMA		= 0xffff6000;
		__DATOS_LMA			= 0xffff7000;
		__TAREA_LMA			= 0xffff8000;
		__TAREA1_LMA		= 0xffff9000;
		__GDT16_TABLE_LMA	= 0xffffd000;
		__SYS_TABLES_LMA 	= 0xffffe000;
		__INIT_32_LMA		= 0xfffff800;
		__FUNCTIONS_ROM_LMA	= 0xfffffa00;
		__RESET_LMA			= 0xfffffff0;

		__STACK_START_16 	= 0x9000; /* SS=0x9000*/
		__STACK_END_16 		= 0x9fff;

		__STACK_START_32 	= 0x1ff08000;
		__STACK_END_32 		= 0x1ff08fff;
		__STACK_SIZE_32 	= ((__STACK_END_32 - __STACK_START_32) / 4); /*32b WORD*/
		
		__TABLE_INIT		= 0x00210000; /*Fin área de guardado de dígitos presionados */

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
		
		.isr __TECLADO_FUNC_VMA :
			AT ( __TECLADO_FUNC_LMA )
			{ *(.isr); } > ram
		__TECLADO_FUNC_SIZE_ = SIZEOF (.isr);

		.sys_table_gdt16 __GDT16_TABLE_VMA :
			AT ( __GDT16_TABLE_LMA )
			{ 	*(.sys_table_gdt16); } > rom

		.sys_tables __SYS_TABLES_VMA :
			AT ( __SYS_TABLES_LMA )
			{ 	*(.sys_table_gdt);
				*(.sys_table_idt); } > ram
		__SYS_SIZE__ = SIZEOF (.sys_tables);

		.datos __DATOS_VMA : 
			AT ( __DATOS_LMA )
			{ *(.datos); } > ram
		__DATOS_SIZE__ = SIZEOF (.datos);

		.tarea_1 __TAREA1_VMA : 
			AT ( __TAREA1_LMA )
			{ *(.tarea_1); } > ram
		__TAREA1_SIZE__ = SIZEOF (.tarea_1);

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
		
		
		
		
		
		
		
		
		
		
		
		
		
		