/*
******************************************************************************
**

**  File        : LinkerScript.ld
**
**
**
**  Abstract    : Linker script for STM32H7 series
**                131072Kbytes FLASH and 192Kbytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32
**
**  Distribution: The file is distributed �as is,� without any warranty
**                of any kind.
**
*****************************************************************************
** @attention
**
** Copyright (c) 2019 STMicroelectronics.
** All rights reserved.
**
** This software is licensed under terms that can be found in the LICENSE file
** in the root directory of this software component.
** If no LICENSE file comes with this software, it is provided AS-IS.
**
******************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = 0x10000;    /* end of RAM */
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x800  /* 1 Kb */;      /* required amount of heap  */
_Min_Stack_Size = 0x800  /* 1 Kb */; /* required amount of stack */
 
/* Specify the memory areas */
MEMORY
{
ROM_ML (rx)          : ORIGIN = 0x08000000, LENGTH = 128K
RAM (rw)            : ORIGIN = 0x24000000, LENGTH = 512K
SDRAM1 (rw)         : ORIGIN = 0xD0000000, LENGTH = 1536K
SDRAM2 (rw)         : ORIGIN = 0xD0180000, LENGTH = 512K
SDRAM3 (rw)         : ORIGIN = 0xD0200000, LENGTH = 6144K
QSPI_ML (rx)         : ORIGIN = 0x90200000 , LENGTH = 30720K

}

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >ROM_ML
  
  .QSPISection : {
 
   . = ALIGN(4);
   *LucidaSans14.o (.rodata .rodata*)
   *LucidaSans16.o (.rodata .rodata*)
   *LucidaSans20.o (.rodata .rodata*)
   *F13_1.o (.rodata .rodata*)
   *F13_ASCII.o (.rodata .rodata*)
   *F6x8.o (.rodata .rodata*)
   . = ALIGN(4); 
   
 } >QSPI_ML

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >ROM_ML

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >ROM_ML

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >ROM_ML
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >ROM_ML
  
 /*  .ExtRamSection :
  {
    . = ALIGN(4);
    _ExtRamSection_start = .;        /* create a global symbol at qspi start */
   /*  *(.ExtRamSection)         /* .qspi sections */
     /**(.ExtRamSection*)        /* .qspi* sections */
    /* . = ALIGN(4);
   /*  _ExtRamSection_end = .;         /* define a global symbols at end of qspi */
    
 /* } >EXT_RAM AT> ROM_ML */
  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >ROM_ML
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >ROM_ML
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >ROM_ML

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> ROM_ML

  
  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

    splash_st_section :
  {
  . = ALIGN(8);
  splash_st = .;
  KEEP(*(splash_st_section ));
  splash_st_end = .;
   } > QSPI_ML  
  default_icon_section :
  {
  . = ALIGN(8);
  default_icon = .;
  KEEP(*(default_icon_section ));
  default_icon_end = .;
   } > QSPI_ML  
     default_logo_section :
  {
  . = ALIGN(8);
  default_logo = .;
  KEEP(*(default_logo_section ));
  default_logo_end = .;
   } > QSPI_ML 
  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
  heap_mem : { *(heap_mem) } >RAM
  .STemWinMemPool : { *(.STemWinMemPool) } >RAM
  .framebuffer (NOLOAD) : { *(.framebuffer) } >SDRAM1
  .jpeg_decoder_buffers (NOLOAD) : { *(.jpeg_decoder_buffers) } >SDRAM2
  .rgb_video_buffers (NOLOAD) : { *(.rgb_video_buffers) } >SDRAM3
  .ExtFlashSection : { *(.ExtFlashSection) } >QSPI_ML
  .ExtRamSection : { *(.ExtRamSection) } >QSPI_ML
  

}


