/* RAM starts at 0x8000_0000 on QEMU virt and on our SoC (D4). */
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text   : { KEEP(*(.text.boot)) *(.text*) }
  .rodata : { *(.rodata*) *(.srodata*) }
  .data   : { *(.data*) *(.sdata*) }
  .bss    : { __bss_start = .; *(.bss*) *(.sbss*) *(COMMON) __bss_end = .; }
  . = ALIGN(16);
  . += 0x4000;
  __stack_top = .;
}
