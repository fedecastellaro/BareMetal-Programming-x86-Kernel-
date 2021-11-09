#include "../inc/sys_types.h"
#include "../inc/functions.h"

extern __VIDEO_VMA;
extern __TABLE_INIT_VMA;
extern indice;
#define FILA_6      6
#define COLUMNA_0   0
extern msg3;

// src = puntero a la variable a guardar, dst = lugar fisico del buffer

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


//Resumen de lo que hago acá:

//Tengo tres funciones en funtions.c:

//_acumular_en_buffer: Guarda todas las teclas que se presionan en __TABLE_INIT_VMA + 30

//_acumular_en_tabla_aux: Guarda todos los numeros que se presionan (y esten en el orden correcto) en una tabla de 16 bytes en __TABLE_INIT_VMA + 20

//_acumular_en_tabla_fin: Copia los ultimos 8 numeros que se presionaron (y que estan en la tabla aux) en la tabla final en __TABLE_INIT_VMA esp
//Apreto cualquier tecla, ordena y guarda los numeros si se los presiona en el orden correcto, y cuando apreto enter guarda los numeros
//en la posicion de memoria de __TABLE_INIT_VMA (0x01210000), respetando el orden pedido ( MSB en cero)


__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra)
{
    //la letra coincide con el indice
    byte aux;
    byte *ptr1 = 0x1210000 + 0x50;
    byte *ptr2 = 0x1210000 + 0x60;

    while(*buffer != 0)
        buffer++; //ubico a mi numero en la ultima posicion

    aux = buffer - (0x1210000 + 0x20); //__TABLE_INIT_VMA + lugar en memoria donde tengo 
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
    
    //Aca guardo los numeros en la direccion __TABLE_INIT_VMA +50 en el orden que se van apretando
    
    //La variable indice se encuentra en la seccion de .datos y esta definida en el main
    //ptr está declarado arriba. Se encarga de apuntar a la posicion de memoria a guardar los numeros
    if ( indice == 0x8) indice = 0;
    
    ptr2[indice] = letra;
    
    ptr1[indice] = letra + 48;
    update_num_ingresados();

    indice++;

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

__attribute__(( section(".functions_rom"))) word __entry (dword dir, byte N)
{
    dir=(dir >> N); //Mueve N veces a la izquierda para luego quedarme con los 10 bits correspondientes
    dir &= 0x000003ff;
    return dir;
}

__attribute__(( section(".functions_rom"))) void __set_PageTable (dword ini_dpt, dword dir_lin, dword ini_pag, byte g, byte pat, byte d, byte a, byte pcd, byte pwt, byte us, byte rw, byte p, byte ps)
{
    dword pte = 0;
    dword dpte = 0;

    dword *dst = (dword *) (ini_dpt +0x1000+0x1000*__entry(dir_lin,22));
    dword *dstd = (dword *) ini_dpt;

    dpte |= (ini_dpt+0x1000+0x1000*__entry(dir_lin,22))& 0xFFFFF000;
    dpte |= (ps << 7);
    dpte |= (a  << 5);
    dpte |= (pcd << 4);
    dpte |= (pwt << 3);
    dpte |= (us << 2);
    dpte |= (rw << 1);
    dpte |= (p  << 0);

    *(dstd + __entry(dir_lin,22)) = dpte;

    pte |= (ini_pag & 0xFFFFF000);
    pte |= (g   << 8);
    pte |= (pat << 7);
    pte |= (d   << 6);
    pte |= (a   << 5);
    pte |= (pcd << 4);
    pte |= (pwt << 3);
    pte |= (us  << 2);
    pte |= (rw  << 1);
    pte |= (p   << 0);

    *(dst + __entry(dir_lin,12)) = pte;
    
}

/*
init_dpt == Direccion fisica de inicio de la DPT -> en mi caso es __PAGTABLE_VMA
_pcd     == Flag PCD -> Cache Disable -> bit CR3.4 -> si es 0 se habilita, 1 deshabilitado
_pwt     == Flag PWT -> Write Through -> bit CR3.3 -> si es 0, el cache de la pagina tiene politica write-back, sino es write through
*/
__attribute__(( section(".functions_rom"))) dword __set_cr3 ( dword init_dpt, byte _pcd, byte _pwt)
{
    dword cr3 = 0;

    cr3 |= (init_dpt & 0xFFFFF000);
    cr3 |= (_pcd << 4);
    cr3 |= (_pwt << 3);

    return cr3;
}


__attribute__(( section(".tarea_1"))) byte __printf_sum (unsigned byte *num)
{
    //0x10000 + LARGO3 + espacio (59*2 + 4) + OFFSET x FILA(0xA0) * Fila a escribir
    byte *aux = 0x10000+ 122 + 0xA0 *3 ; 
    dword total = 0;
    byte cant_dig[10];
    dword num_aux = 0;
    byte i = 0, x;

    while ( *num != 0)
    {
        total += *num;
        num--;
    }
    if (!total)
        {
            *aux = 48;
            *(aux+1) = 0x07;
            return 1;
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

__attribute__(( section(".tarea_1"))) void update_num_ingresados ( void )
{
    char str1[]= "Ultimos numeros ingresados: 0x";

    __my_printf ( FILA_6, COLUMNA_0, str1, sizeof(str1));

    __my_printf( FILA_6, sizeof(str1)-1, 0x1210050, 0xF );
}


__attribute__(( section(".tarea_1"))) byte __my_printf ( unsigned byte fila, unsigned byte columna, unsigned byte *buffer, unsigned byte largo)
{   
    byte *aux = 0x10000 + (0xA0)*fila + columna*2;
    byte i; 
    for ( i = largo; i != 0; aux+=2, buffer++ , i--)
    {
        *(aux) = *buffer;
        *(aux+1) = 0x07;
    }
    return aux;
}

/*****************************************************************************
 * @brief   Segun los ultimos numeros que fueron apretados y guardados ( en 0x1210060 ),
 *          esta funcion arma un numero en hexadecimal de los mismos y lo guarda en 
 *          formato unsigned long en 0x1210074
 * @return  Devuelve el numero equivalente convertido en Hexadecimal
 * @arg     VOID
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".tarea_1"))) unsigned int suma_a_hexa ( void )
{
    byte *ptr1 = 0x1210000 + 0x60;
    unsigned long *ptr2 = 0x1210000 + 0x70;
    unsigned long aux = 0;
    byte i,x;

    //Este for se encarga de desplazar cada numero al nibble que corresponda del valor hexa que representa
    //En la variable auxiliar AUX

    for ( i = 7, x = 0; x != 8 ; i--, x++) //Tomo i = 7 xq el numero máximo admitido para una direccion son 8 (0xFFFFFFFF)
        aux += (ptr1[x] << (i*4));

    //Guardo mi numero en el valor de memoria correspondiente.
    *ptr2 += aux;

    return aux;
}

/*****************************************************************************
 * @brief   Limpia el valor de la posicion de memoria 0x1210060, que es donde 
 *          se guardan los ultimos numeros ingresados.
 *          Tambien limpia el valor de la variable "indice"
 * @return  VOID
 * @arg     VOID
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".tarea_1"))) void clean_numeros ( void )
{
    unsigned long *ptr1 = 0x1210000 + 0x50;
    unsigned long *ptr2 = 0x1210000 + 0x60;
    
    byte i = 0;

    for ( i = 0; i <= 7; i++)
        {
        ptr1[i] = 0;
        ptr2[i] = 0;
        }
    indice = 0;
    return;
}