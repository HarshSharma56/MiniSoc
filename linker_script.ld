/* Linker Script for MiniSoC */

ENTRY(_start)

MEMORY {
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
  RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 256K
}

SECTIONS {

  /* Code and read-only data in ROM */
  .text : {
    *(.text*)       /* All code */
    *(.rodata*)     /* Read-only data */
    *(.init)
    *(.fini)
    . = ALIGN(4);
  } > ROM

  /* Initialized data in RAM, loaded from ROM */
  .data : AT (ADDR(.text) + SIZEOF(.text)) {
    __data_start = .;
    *(.data*)
    . = ALIGN(4);
    __data_end = .;
  } > RAM

  /* Needed for copying data from ROM to RAM */
  __data_load_start = LOADADDR(.data);

  /* Uninitialized data in RAM (zero-initialized) */
  .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > RAM

  /* Stack at top of RAM */
  .stack (NOLOAD) : {
    __stack_top = ORIGIN(RAM) + LENGTH(RAM);
  }

  /* Define symbols for startup code */
  __global_pointer$ = __data_start + 0x800;
  __stack_bottom = __bss_end;
}
