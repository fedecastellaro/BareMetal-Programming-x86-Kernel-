#define _OK_ 1
#define _ERROR_ -1

__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(const dword *src, dword *dst, dword length);