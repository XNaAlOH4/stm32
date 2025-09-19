ENTRY(reset)

MEMORY
{
	FLASH	(rx) : ORIGIN = 0x08000000, LENGTH = 128K
	RAM	(rwx): ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS
{
	.isr_vector :
	{
		KEEP(*(.isr_vector))
	} > FLASH
	.text :
	{
		*(.text*)
		*(.rodata*)
	} > FLASH

	.data :
	{
		*(.data)
	} > RAM AT > FLASH

	.bss :
	{
		*(.bss*)
		*(COMMON)
	} > RAM
}
