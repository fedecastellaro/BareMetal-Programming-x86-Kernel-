#define _OK_ 1
#define _ERROR_ -1
#define byte char

__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(const dword *src, dword *dst, dword length);
__attribute__(( section(".functions_rom"))) byte _acumular_en_buffer ( unsigned byte *buffer, unsigned byte letra );
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_fin ( unsigned byte *src, unsigned byte *dst);
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra);
__attribute__(( section(".functions_rom"))) dword __set_cr3 ( dword init_dpt, byte _pcd, byte _pwt);
__attribute__(( section(".functions_rom"))) void __set_PageTable (dword ini_dpt, dword dir_lin, dword ini_pag, byte g, byte pat, byte d, byte a, byte pcd, byte pwt, byte us, byte rw, byte p, byte ps);

__attribute__(( section(".tarea_1"))) byte __my_printf  ( unsigned byte fila, unsigned byte columna, unsigned byte *buffer, unsigned byte largo);
__attribute__(( section(".tarea_1"))) byte __printf_sum ( unsigned byte *num);
__attribute__(( section(".tarea_1"))) void update_num_ingresados ( void );
__attribute__(( section(".tarea_1"))) unsigned int suma_a_hexa ( void );
__attribute__(( section(".tarea_1"))) void clean_numeros ( void );
