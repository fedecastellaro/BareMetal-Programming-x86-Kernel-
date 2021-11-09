#include "../inc/sys_types.h"
#include "../inc/functions.h"

extern __VIDEO_VMA;
extern __TABLA_DIGITO_VMA;
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

//_acumular_en_buffer: Guarda todas las teclas que se presionan en __TABLA_DIGITO_VMA + 30

//_acumular_en_tabla_aux: Guarda todos los numeros que se presionan (y esten en el orden correcto) en una tabla de 16 bytes en __TABLA_DIGITO_VMA + 20

//_acumular_en_tabla_fin: Copia los ultimos 8 numeros que se presionaron (y que estan en la tabla aux) en la tabla final en __TABLA_DIGITO_VMA esp
//Apreto cualquier tecla, ordena y guarda los numeros si se los presiona en el orden correcto, y cuando apreto enter guarda los numeros
//en la posicion de memoria de __TABLA_DIGITO_VMA (0x01210000), respetando el orden pedido ( MSB en cero)

// En __TABLA_DIGITO_VMA + 0x60 empiezo a guardar todos los numeros
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra)
{
    //la letra coincide con el indice
    byte aux;
    byte *ptr1 = 0x1210000 + 0x50;
    byte *ptr2 = 0x1210000 + 0x60;

    while(*buffer != 0)
        buffer++; //ubico a mi numero en la ultima posicion

    aux = buffer - (0x1210000 + 0x20); //__TABLA_DIGITO_VMA + lugar en memoria donde tengo 
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
    
    //Aca guardo los numeros en la direccion __TABLA_DIGITO_VMA +50 en el orden que se van apretando
    
    //La variable indice se encuentra en la seccion de .datos y esta definida en el main
    //ptr está declarado arriba. Se encarga de apuntar a la posicion de memoria a guardar los numeros
    if ( indice == 16) indice = 0;
    
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

__attribute__(( section(".functions_rom"))) void __set_PageTable (dword ini_dpt, dword dir_lin, dword ini_pag, byte dpte_us, byte pte_us, byte dpte_rw, byte pte_rw )
{
    dword pte = 0;
    dword dpte = 0;

    dword *dst = (dword *) (ini_dpt +0x1000+0x1000*__entry(dir_lin,22));
    dword *dstd = (dword *) ini_dpt;

    dpte |= (ini_dpt+0x1000+0x1000*__entry(dir_lin,22))& 0xFFFFF000;
    dpte |= (PAG_PS_4K  << 7);
    dpte |= (PAG_A_NO   << 5);
    dpte |= (PAG_PCD_NO << 4);
    dpte |= (PAG_PWT_NO << 3);
    dpte |= (dpte_us    << 2);
    dpte |= (dpte_rw    << 1);
    dpte |= (PAG_P_SI   << 0);

    *(dstd + __entry(dir_lin,22)) = dpte;

    pte |= (ini_pag & 0xFFFFF000);
    pte |= (PAG_G_SI   << 8);
    pte |= (PAG_PAT_NO << 7);
    pte |= (PAG_D_NO   << 6);
    pte |= (PAG_A_NO   << 5);
    pte |= (PAG_PCD_NO << 4);
    pte |= (PAG_PWT_NO << 3);
    pte |= (pte_us  << 2);
    pte |= (pte_rw  << 1);
    pte |= (PAG_P_SI   << 0);

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

__attribute__(( section(".functions_rom"))) byte __printf_sum ( unsigned byte fila, unsigned byte columna, unsigned long sumando)
{
    //0x10000 + LARGO3 + espacio (59*2 + 4) + OFFSET x FILA(0xA0) * Fila a escribir
    byte *aux = 0x10000 + (0xA0)*fila + columna*2 + 8*2;
    dword total = 0;
    unsigned byte d = 0;
    unsigned byte cant=0;

    while (cant<8)    
    {
        d=sumando%16;
        sumando=sumando>>4;
        if ( d > 9) d += 7;
        *aux = d + '0';
        *(aux+1) = 0x07;
        aux-=2;      
        cant++;
    }
    return 1;
}

__attribute__(( section(".functions_rom"))) void update_num_ingresados ( void )
{
    char str1[]= "Ultimos numeros ingresados: 0x";

    __my_printf ( FILA_6, COLUMNA_0, str1, sizeof(str1));

    __my_printf( FILA_6, sizeof(str1)-1, 0x1210050, 16 );
}


__attribute__(( section(".functions_rom"))) byte __my_printf ( unsigned byte fila, unsigned byte columna, unsigned byte *buffer, unsigned byte largo)
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
 *          formato unsigned long en *posicion_tabla (que se encuentra a partir de 0x1210070)
 * @return  Devuelve el numero equivalente convertido en Hexadecimal
 * @arg     VOID
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) unsigned int suma_a_hexa ( unsigned long *posicion_tabla )
{
    byte *ptr1 = 0x1210000 + 0x60;
    byte *ptr1_aux = 0x1210000 + 0x68;
    unsigned long *ptr2 = posicion_tabla;
    unsigned long *ptr2_aux = 0x1210070 + 4;
    unsigned long aux = 0;
    byte i,x;

    
    //Este for se encarga de desplazar cada numero al nibble que corresponda del valor hexa que representa
    //En la variable auxiliar AUX

   if ( indice > 8 )
    {
    for ( i = indice-9, x = 0; i != 0; i--, x++) //Tomo i = 7 xq el numero máximo admitido para una direccion son 8 (0xFFFFFFFF)
        aux |= (ptr1_aux[i] << (x*4));

    aux |= ptr1_aux[0] << (x*4);       

    *ptr2_aux |= aux;

    aux = 0;

    for ( i = 7, x = 0; i != 0; i--, x++) //Tomo i = 7 xq el numero máximo admitido para una direccion son 8 (0xFFFFFFFF)
        aux |= (ptr1[i] << (x*4));
    
    aux |= ptr1[0] << (x*4);       
    *ptr2 |= aux;
    
    }

    else
    {
    for ( i = indice-1, x = 0; i != 0; i--, x++) //Tomo i = 7 xq el numero máximo admitido para una direccion son 8 (0xFFFFFFFF)
        aux |= (ptr1[i] << (x*4));
    
    aux |= ptr1[0] << (x*4);       
    *ptr2 += aux;

    }

    return *ptr2_aux;

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
__attribute__(( section(".functions_rom"))) void clean_numeros ( void )
{
    unsigned long *ptr1 = 0x1210000 + 0x50;
    
    byte i = 0;

    for ( i = 0; i <= 7; i++)
        {
        ptr1[i] = 0;
        }
    indice = 0;
    return;
}