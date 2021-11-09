#include "../inc/sys_types.h"
#include "../inc/functions.h"

__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(const dword *src, dword *dst, dword length)
{
    byte status = _ERROR_;

    if (!length)
            return _OK_;
    else
    {
        while(length)
        {
            length--;
            *dst++ = *src++;
        }    
    }
    
    if (!length)
        status = _OK_;
    
    return (status);
}

// src = puntero a la variable a guardar, dst = lugar fisico del buffer
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra)
{
    //la letra coincide con el indice
    byte aux;

    while(*buffer != 0)
        buffer++; //ubico a mi numero en la ultima posicion

    aux = buffer - 0x21020;
    //buffer = 30 31..
    if ( letra == 0x0b) letra = 0;  // igual = 0
    else letra--; //porque los valores en hexa que recibo son iguales al numero-1 ( excepto el cero )

    if ( aux < 9)
    {
    if ( aux == 0 && letra == 1) *buffer = letra;
    else if ((aux + 1) == letra) *buffer = letra; 
    }

    else
    {
    if ( (aux-0x9) == 0 && letra == 1) *buffer = letra;
    else if ((aux-0x9+1) == letra) *buffer = letra;
    }
    
    return letra;
}

__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_fin ( unsigned byte *src, unsigned byte *dst)
{
    byte i,x;

    for (i = 0; i <= 0x0F; i++ ) dst[i] = 0; //limpio mi buffer destino

    for (i = 0; src[i] != 0; i++); //obtengo tamaño de mi tabla auxiliar

    if ( i > 9 )
    {
        for (x = 0; x < 9 ; x++)
            *(dst+0x0F-x) = src[i-x-1];
    }

    else
    {
        for (x = 0; x <= i ; x++)
        *(dst+0x0F-x) = src[i-x-1];    
    }


    return _OK_;

}

__attribute__(( section(".functions_rom"))) byte _acumular_en_buffer ( unsigned byte *buffer, unsigned byte letra)
{
    while(*buffer != 0)
        buffer++;
    
    *buffer = letra;

    return _OK_;

}

__attribute__(( section(".tarea_1"))) byte __printf_sum (unsigned byte *num)
{
    byte *aux = 0xB80A0; // b8000 + a0 = Comienzo de la segunda fila -> 80 * 2
    dword total = 0;
    byte cant_dig[10];
    dword num_aux = 0;
    byte i = 0, x;

    while ( *num != 0)
    {
        total += *num;
        num--;
    }

    for ( num_aux = total, i = 0 ; num_aux != 0; i++)
    {
        cant_dig[i] = num_aux % 10;
        num_aux /= 10;
    }
    i--;

    if (i >= 1)
    {
        for(x = 0; i != 0; i--, x++)
        {
        *(aux+x*2) = cant_dig[i] + 48;
        *(aux+x*2+1) = 0x07;
        }
        
        *(aux+x*2) = cant_dig[0] + 48;
       *(aux+x*2+1) = 0x07;
    }

    else
    {
        *aux = cant_dig[0]+48;
        *(aux+1) = 0x07;
    }

    return 1;
}

__attribute__(( section(".tarea_1"))) byte __my_printf ( unsigned byte *buffer, unsigned byte largo)
{   
    byte *aux = 0xB8000;
    byte i; 
    for ( i = largo; i != 0; aux+=2, buffer++ , i--)
    {
        *(aux) = *buffer;
        *(aux+1) = 0x07;
    }
    return aux;
}