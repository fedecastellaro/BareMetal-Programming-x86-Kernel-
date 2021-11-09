#define _OK_ 1
#define _ERROR_ -1
#define byte char

#define     PAG_PWT_SI      1
#define     PAG_PWT_NO      0
#define     PAG_PCD_SI      1
#define     PAG_PCD_NO      0
#define     PAG_P_SI        1
#define     PAG_P_NO        0
#define     PAG_RW_W        1
#define     PAG_RW_R        0
#define     PAG_US_USR      1        
#define     PAG_US_SUP      0        
#define     PAG_A_SI        1
#define     PAG_A_NO        0
#define     PAG_PS_4M       1
#define     PAG_PS_4K       0
#define     PAG_D_SI        1
#define     PAG_D_NO        0
#define     PAG_PAT_SI      1
#define     PAG_PAT_NO      0
#define     PAG_G_SI        1
#define     PAG_G_NO        0


__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(const dword *src, dword *dst, dword length);
__attribute__(( section(".functions_rom"))) byte _acumular_en_buffer ( unsigned byte *buffer, unsigned byte letra );
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_fin ( unsigned byte *src, unsigned byte *dst);
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra);
__attribute__(( section(".functions_rom"))) dword __set_cr3 ( dword init_dpt, byte _pcd, byte _pwt);
__attribute__(( section(".functions_rom"))) void __set_PageTable (dword ini_dpt, dword dir_lin, dword ini_pag, byte dpte_us, byte pte_us, byte dpte_wr, byte pte_rw );

__attribute__(( section(".functions_rom"))) byte __my_printf  ( unsigned byte fila, unsigned byte columna, unsigned byte *buffer, unsigned byte largo);
__attribute__(( section(".functions_rom"))) byte __printf_sum ( unsigned byte fila, unsigned byte columna, unsigned long sumando);
__attribute__(( section(".functions_rom"))) void update_num_ingresados ( void );
__attribute__(( section(".functions_rom"))) unsigned int suma_a_hexa ( unsigned long *posicion_tabla );
__attribute__(( section(".functions_rom"))) void clean_numeros ( void );
