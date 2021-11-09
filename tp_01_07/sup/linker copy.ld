	/* TP 1.8*/

	ENTRY (reset)
		__EH_FRAME			= 0x00060000;
		__DATA_NOT_INIT 	= 0x00050000;
		
		__STACK_START_16 	= 0x9000; /* SS=0x9000*/
		__STACK_END_16 		= 0x9fff;
		__IDTR				= 0x00100000; /* Nos aprovechamos del Shadow*/
		__GDTR				= 0x000fd000; /* Nos aprovechamos del Shadow*/
		__STACK_START_32 	= 0x1ff08000;
		__STACK_END_32 		= 0x1ff08fff;
		__STACK_SIZE_32 	= ((__STACK_END_32 - __STACK_START_32) / 4); /*32b WORD*/
		__TABLE_INIT		= 0x00210000; /*Inicio área de guardado de dígitos presionados*/
		__TABLE_END			= 0x00220000; /*Fin área de guardado de dígitos presionados */
		__TABLE_SIZE 		= (__TABLE_END - __TABLE_INIT); /*8b Byte*/

		/*   VMA */
		__TECLADO_FUNC_VMA	= 0x00000000; /* Función de Para Teclado con Int*/
		__NUCLEO_VMA		= 0x00200000;
		__DATOS_VMA			= 0x00202000;
	 
		__INIT_16_VMA		= 0xffff0000;
		__INIT_32_VMA		= 0xfffff800;
		__FUNCTIONS_ROM_VMA	= 0xfffffa00;
		__RESET_VMA			= 0xfffffff0;

		__SYS_TABLE_GDT_VMA = 0xffffd000;
		__SYS_TABLE_IDT_VMA	= 0x00100000;/* Nos aprovechamos del Shadow*/

		/*    LMA   */
		__SYS_TABLE_GDT_LMA	= 0xffffd000;
		__SYS_TABLE_IDT_LMA = 0xffffe000;

		__INIT_16_LMA		= 0xffff0000;
		__TECLADO_FUNC_LMA	= 0xffff1000; /* Función de Para Teclado*/
		__NUCLEO_LMA		= 0xffff2000;
		__DATOS_LMA			= 0xfffff100;
		__INIT_32_LMA		= 0xfffff800;
		__FUNCTIONS_ROM_LMA	= 0xfffffa00;
		__RESET_LMA			= 0xfffffff0;
		
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
		
		.rutina_teclado __TECLADO_FUNC_VMA :
			AT ( __TECLADO_FUNC_LMA )
			{ *(.rutina_teclado); } > ram
		__TECLADO_FUNC_SIZE_ = SIZEOF (.rutina_teclado);

		.sys_table_gdt __SYS_TABLE_GDT_VMA :
			AT ( __SYS_TABLE_GDT_LMA )
			{ * (.sys_table_gdt); } > rom
		__SYS_GDT_SIZE__ = SIZEOF (.sys_table_gdt);

		.sys_table_idt __SYS_TABLE_IDT_VMA :
			AT ( __SYS_TABLE_IDT_LMA )
			{ * (.sys_tables_idt); } > ram
		__SYS_IDT_SIZE__ = SIZEOF (.sys_table_idt);

		.datos __DATOS_VMA : 
			AT ( __DATOS_LMA )
			{ *(.datos); } > ram
		__DATOS_SIZE__ = SIZEOF (.datos);

		.codigo_init16 __INIT_16_VMA :
			AT ( __INIT_16_LMA )
			{ *(.ROM_init); } > rom
		
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
		
		
		
		
		
		
		
		
		
		
		
		
		
		