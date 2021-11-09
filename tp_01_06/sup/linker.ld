	/* Linker básico*/

	ENTRY (reset)
		__EH_FRAME			= 0x00060000;
		__DATA_NOT_INIT 	= 0x00050000;
		
		__STACK_START_16 	= 0x9000; /* SS=0x9000*/
		__STACK_END_16 		= 0x9fff;

		/*PILA*/
		__STACK_START_32 	= 0x1ff08000; 
		__STACK_END_32 		= 0x1ff08fff;
		__STACK_SIZE_32 	= ((__STACK_END_32 - __STACK_START_32) / 4); /*32b WORD*/
		
		/*DATOS*/
		__DATOS_VMA			= 0x00202000;

		/*TABLA DE DIGITOS*/
		__STACK_DIGITOS_ST	= 0x00210000;
		__STACK_DIGITOS_END	= 0x0021ffff;
		__STACK_DIGITOS_SIZE  = (__STACK_DIGITOS_END - __STACK_DIGITOS_ST);

		__BOOT_SEG			= 0xf0000;
		/*   VMA */

		/*Direccion para las rutinas de teclado*/
		__TECLADO_FUNC_VMA	= 0x00000000; /*Rutina teclado -> .DATOS*/
		/*Direccion para nucleo del sistema (KERNEL)*/
		__NUCLEO_VMA		= 0x00200000;
		__INIT_16_VMA		= 0xffff0000; /*Secuencia inicio ROM (INIT16)*/
		__INIT_32_VMA		= 0xfffff800;
		__FUNCTIONS_ROM_VMA	= 0xfffffc00;
		__SYS_TABLES_VMA	= 0xfffffd00;
		__RESET_VMA			= 0xfffffff0; /*resetVector*/
		
		/*    LMA   */
		__INIT_16_LMA		= 0xffff0000;
		__TECLADO_FUNC_LMA	= 0xffff1000;
		__NUCLEO_LMA		= 0xffff2000;
		__DATOS_LMA			= 0xffff3000;
		__INIT_32_LMA		= 0xfffff800;
		__FUNCTIONS_ROM_LMA	= 0xfffffc00;
		__SYS_TABLES_LMA	= 0xfffffd00;
		__RESET_LMA			= 0xfffffff0;
		
	MEMORY
	{
		ram(rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000 /* 2^32 (4G) - 2^16 (64K) */
		rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xffff
	}
	
	SECTIONS
	{
		.rutina_teclado __TECLADO_FUNC_VMA : /*0x00000000*/
			AT ( __TECLADO_FUNC_LMA )
			{ *(.rutina_teclado); } > ram
		__TECLADO_FUNC_SIZE_ = SIZEOF(.rutina_teclado);

		.nucleo __NUCLEO_VMA :
			AT ( __NUCLEO_LMA )
			{ *(.nucleo); } > ram
		__NUCLEO_SIZE__ = SIZEOF (.nucleo);

		.datos __DATOS_VMA :
			AT ( __DATOS_LMA )
			{ *(.datos); } > ram
		__DATOS_SIZE__ = SIZEOF (.datos);

		.functions_rom __FUNCTIONS_ROM_VMA :
			AT ( __FUNCTIONS_ROM_LMA )
			{ * (.functions_rom); } > rom

		.codigo_init16 0xffff0000 : /*__INIT_16_VMA*/
			AT ( 0xffff0000 ) 		/*__INIT_16_LMA*/
			{ *(.ROM_init); } > rom
		
		.codigo_init32 __INIT_32_VMA :
			AT ( __INIT_32_LMA )
			{ *(.start32); } > rom

		.sys_tables __SYS_TABLES_VMA :
			AT ( __SYS_TABLES_LMA )
			{ * (.sys_tables); } > rom

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
	