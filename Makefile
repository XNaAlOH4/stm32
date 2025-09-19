all:
	arm-none-eabi-as -mcpu=cortex-m3 -mthumb button.s -o button.o
	arm-none-eabi-ld -T stm32.ld button.o -o button.elf
	arm-none-eabi-objcopy button.elf -O binary button.bin
