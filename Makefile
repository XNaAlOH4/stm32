all:
	arm-none-eabi-as -mcpu=cortex-m3 -mthumb adc.s -o adc.o
	arm-none-eabi-ld -T stm32.ld adc.o -o adc.elf
	arm-none-eabi-objcopy adc.elf -O binary adc.bin
