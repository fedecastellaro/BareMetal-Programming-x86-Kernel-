.PHONY: clean

BINPATH = ./bin/
DOCPATH = ./doc/
INCPATH = ./inc/
LIBPATH = ./lib/
SRCPATH = ./src/

AC = nasm
CC = gcc
AFLAGS = -f elf32
CFLAGS = -c -m32 -fno-stack-protector -fno-asynchronous-unwind-tables -Wall -fno-PIC

LDFLAGS = -z max-page-size=0x01000 --oformat=binary -m elf_i386

LDSCRIPT = ./sup/linker.ld
ODFLAGS = -CprsSx --prefix-addresses
#en objs guardo todos mis objetos elf
OBJS = $(BINPATH)init32.elf $(BINPATH)reset.elf $(BINPATH)sys_tables.elf $(BINPATH)init16.elf $(BINPATH)main.elf $(BINPATH)funtions.elf
SRC_NAME = mi_bios

all: $(BINPATH)$(SRC_NAME).bin $(BINPATH)$(SRC_NAME).elf bochs
	mkdir -p doc
	hexdump -C $(BINPATH)$(SRC_NAME).bin > $(DOCPATH)$(SRC_NAME)_hexdump.txt
	objdump $(ODFLAGS) $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_objdump.txt
	readelf -a $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_readelf.txt


$(BINPATH)$(SRC_NAME).bin: $(OBJS)
	ld $(LDFLAGS) -T $(LDSCRIPT) $(OBJS) -o $@ -Map $(SRC_NAME).map

$(BINPATH)$(SRC_NAME).elf: $(OBJS)
	ld -z max-page-size=0x01000 -m elf_i386 -T $(LDSCRIPT) $(OBJS) -o $@

$(BINPATH)main.elf: $(SRCPATH)main.s
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_tables.elf: $(SRCPATH)sys_tables.s
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)reset.elf: $(SRCPATH)reset.s
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init16.elf: $(SRCPATH)init16.s
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init32.elf: $(SRCPATH)init32.s
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)funtions.elf: $(SRCPATH)funtions.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

bochs:
	bochs -qf bochsrc

clean:
	rm $(BINPATH)*.bin $(BINPATH)*.elf $(BINPATH)*.lst *.map

help:
	@echo	''
	@echo	'Uso:'
	@echo	'  make all:      Compila y patchea Checksum'
	@echo	'  make bochs:    Ejecuta bochs con el archivo de configuracion de la version 2.6.9'
	@echo	'  make clean:    Elimina archivos auxiliares'
	@echo	''