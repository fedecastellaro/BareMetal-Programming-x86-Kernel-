#define _OK_ 1
#define _ERROR_ -1
#define byte char

__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(const dword *src, dword *dst, dword length);
__attribute__(( section(".functions_rom"))) byte _acumular_en_buffer ( unsigned byte *buffer, unsigned byte letra );
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_fin ( unsigned byte *src, unsigned byte *dst);
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra);
__attribute__(( section(".functions_rom"))) byte __my_printf ( unsigned byte *buffer, unsigned byte largo);
__attribute__(( section(".functions_rom"))) byte __printf_sum ( unsigned byte *num);
