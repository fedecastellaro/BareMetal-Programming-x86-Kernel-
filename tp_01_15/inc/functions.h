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


//_acumular_en_buffer: Guarda todas las teclas que se presionan en __TABLA_DIGITO_VMA + 30

//_acumular_en_tabla_aux: Guarda todos los numeros que se presionan (y esten en el orden correcto) en una tabla de 16 bytes en __TABLA_DIGITO_VMA + 20

//_acumular_en_tabla_fin: Copia los ultimos 8 numeros que se presionaron (y que estan en la tabla aux) en la tabla final en __TABLA_DIGITO_VMA esp
//Apreto cualquier tecla, ordena y guarda los numeros si se los presiona en el orden correcto, y cuando apreto enter guarda los numeros
//en la posicion de memoria de __TABLA_DIGITO_VMA (0x01210000), respetando el orden pedido ( MSB en cero)


__attribute__(( section(".functions_rom"))) byte _acumular_en_buffer ( unsigned byte *buffer, unsigned byte letra );
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_fin ( unsigned byte *src, unsigned byte *dst);
__attribute__(( section(".functions_rom"))) byte _acumular_en_tabla_aux ( unsigned byte *buffer, unsigned byte letra);

/**********************************************************************************
 * @Protot  __set_cr3
 * 
 * @brief   Prepara el dword correspondiente a la CR3 que se necesita según los otros
 *          argumentos
 * 
 * @return  dword -> CR3 
 * 
 * @arg     _pwt = valor a escribir en el bit _pwt del CR3
 *          _pcd = valor a escribir en el bit _pcd del CR3
 *          init_dpt = posicion de la CR3 en cuestion
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 **********************************************************************************/
__attribute__(( section(".functions_rom"))) dword __set_cr3 ( dword init_dpt, byte _pcd, byte _pwt);

/*****************************************************************************
 * @Protot  __set_PageTable
 * 
 * @brief   Funcion que carga las entry al directorio de tabla de paginas y de la 
 *          la tabla de pagina, el valor correspondiente a sus privilegios
 * 
 * @return  VOID
 * 
 * @arg     pte_wr = set privilegio W/R  entry de la tabla de paginas
 *          dpte_wr = set privilegio W/R entry del directorio    
 *          pte_us  = set privilegio U/S entry de la tabla de paginas
 *          dpte_us = set privilegio U/S entry del directorio
 *          ini_pag = dirección fisica a paginar
 *          dir_lin = direccion lineal a pagiar
 *          init_dipt = direccion fisica del comienzo de la DTP
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) void __set_PageTable (dword ini_dpt, dword dir_lin, dword ini_pag, byte dpte_us, byte pte_us, byte dpte_wr, byte pte_rw );

/*****************************************************************************
 * @Protot  __verificar_direccion
 * 
 * @brief   Verifica que la página sea accesible y tenga permisos unicamente
 *          de usuario ( para que una task de DPL = 11 no pueda acceder a paginas de kernel) 
 * 
 * @return  Devuelve el resultado de la verificacion
 *          1 = _OK_ = Pasa Verificacion
 *          0 = _ERROR = No Pasa Verificacion
 * 
 * @arg     dir_lin = direccion lineal a checkear
 *          init_dipt = direccion fisica del comienzo de la DTP
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) unsigned byte __verificar_direccion (dword ini_dpt, dword dir_lin );

/**********************************************************************************
 * @Protot  __my_printf
 * 
 * @brief   Escribe en la posicion de pantalla que se le comande, el valor del buffer
 *          pasado
 * 
 * @return  
 *          1 = _OK_ = Print con exito
 *          0 = _ERROR = No Pasa Verificacion
 * 
 * @arg     largo   = Largo del buffer
 *          *buffer = posicion de comienzo del buffer a mostrar en pantalla
 *          columna = columna de la pantalla donde empezar a escribir
 *          fila    = fila de la pantalla donde empezar a escribir
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 **********************************************************************************/
__attribute__(( section(".functions_rom"))) byte __my_printf  ( unsigned byte fila, unsigned byte columna, unsigned byte *buffer, unsigned byte largo);

/**********************************************************************************
 * @Protot  __printf_sum
 * 
 * @brief   Lee el numero equivalente a la suma total de los numeros (numero en decimal de 64 bits)
 *          y lo muestra en su pantalla en formato Hexadecimal
 * 
 * @return  
 *          1 = _OK_ = Print con exito
 *          0 = _ERROR = No Pasa Verificacion
 * 
 * @arg     sumandoLSB = Parte menoss significativa de la variable de 64bits
 *          sumandoMSB = Parte mas significativa de la variable de 64bits
 *          columna = Columna de la pantalla donde empezar a escribir
 *          fila    = fila de la pantalla donde empezar a escribir
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 **********************************************************************************/
__attribute__(( section(".functions_rom"))) unsigned long __printf_sum ( unsigned byte fila, unsigned byte columna, unsigned long sumandoMSB, unsigned long sumandoLSB );

/*****************************************************************************
 * @Proto   update_num_ingresados
 * 
 * @brief   Muestra los numeros que se ven ingresando en pantalla
 * 
 * @return  VOID
 * 
 * @arg     VOID
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) void update_num_ingresados ( void );

/*****************************************************************************
 * @brief   Segun los ultimos numeros que fueron apretados y guardados ( en 0x1210060 ),
 *          esta funcion arma un numero en hexadecimal de 64 bits de los mismos y lo guarda en 
 *          en *posicion_tabla (que se encuentra a partir de 0x1210070)
 * 
 * @return  Devuelve el numero equivalente convertido en Hexadecimal
 * 
 * @arg     Posicion del comienzo del numero en la tabla
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) unsigned long suma_a_hexa ( unsigned long *posicion_tabla );

/*****************************************************************************
 * @brief   Limpia el valor de la posicion de memoria 0x1210050, que es donde 
 *          se guardan los ultimos numeros ingresados.
 *          Tambien limpia el valor de la variable "indice"
 * 
 * @return  VOID
 * 
 * @arg     VOID
 * 
 * @author  Castellaro, Federico
 * @legajo  153347-2
 *
 *****************************************************************************/
__attribute__(( section(".functions_rom"))) void clean_numeros ( void );