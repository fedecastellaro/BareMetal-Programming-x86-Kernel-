	/* Linker básico*/

	ENTRY (reset)
		__EH_FRAME			= 0x00060000;
		__DATA_NOT_INIT 	= 0x00050000;
		
		__STACK_START_16 	= 0x9000; /* SS=0x9000*/
		__STACK_END_16 		= 0x9fff;
		__STACK_START_32 	= 0x1ff08000;
		__STACK_END_32 		= 0x1ff08fff;
		__STACK_SIZE_32 	= ((__STACK_END_32 - __STACK_START_32) / 4); /*32b WORD*/
		
		__BOOT_SEG			= 0xf0000;
		/*   VMA */
		__FUNCTIONS_VMA		= 0x00000000;
		__KERNEL_32_VMA		= 0x00300000;
		
		__INIT_16_VMA		= 0xffff0000;
		__INIT_32_VMA		= 0xfffff800;
		__FUNCTIONS_ROM_VMA	= 0xfffffc00;
		__SYS_TABLES_VMA	= 0xfffffd00;
		__RESET_VMA			= 0xfffffff0;
		
		/*    LMA   */
		__INIT_16_LMA		= 0xffff0000;
		
		__FUNCTIONS_LMA		= 0xffff1000;
		__KERNEL_32_LMA		= 0xffff2000;
		
		__INIT_32_LMA		= 0xfffff800;
		__FUNCTIONS_ROM_LMA	= 0xfffffc00;
		__SYS_TABLES_LMA	= 0xfffffd00;
		__RESET_LMA			= 0xfffffff0;
		
	MEMORY
	{
		ram(rwx) : ORIGIN = 0x00000000, LENGTH = 0xffff0000 /* 2^32 (4G) - 2^16 (64K) */
		rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 64K
	}
	
	SECTIONS
	{
		.codigo_kernel32 __KERNEL_32_VMA :
			AT ( __KERNEL_32_LMA )
			{ *(.kernel32); } > ram
		__codigo_kernel32_size = SIZEOF(.codigo_kernel32);
		
		.functions __FUNCTIONS_VMA :
			AT ( __FUNCTIONS_LMA )
			{ *(.functions); } > ram
		__function_size = SIZEOF (.functions);
		
		.codigo_init16 __INIT_16_VMA :
			AT ( __INIT_16_LMA )
			{ *(.ROM_init); } > rom
		
		.codigo_init32 __INIT_32_VMA :
			AT ( __INIT_32_LMA )
			{ *(.start32); } > rom
		
		.functions_rom __FUNCTIONS_ROM_VMA :
			AT ( __FUNCTIONS_ROM_LMA )
			{ * (.functions_rom); } > rom

		.data __SYS_TABLES_VMA :
			AT ( __SYS_TABLES_LMA )
			{ * (.sys_tables); } > rom

		.codigo_reset __RESET_VMA :
			AT ( __RESET_LMA )
			{ * (.resetVector); } > rom
			
		/*.fill_rom :
			{ FILL(0x90);
				. = ORIGIN(rom) + LENGTH(rom) - 1;
				BYTE(0x90);			
			} > rom
		*/
		.end_rom 0xffffffff :
			AT ( 0xffffffff )
			{
				BYTE(0x90);
			}
	}
		
		
		
		
		
		
		
		
		
		
		
		
		
		