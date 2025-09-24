all:
	arm-none-eabi-as -mcpu=cortex-m3 -mthumb adc.s -o adc.o
	arm-none-eabi-ld -T stm32.ld adc.o -o adc.elf
	arm-none-eabi-objcopy adc.elf -O binary adc.bin
blink:
	arm-none-eabi-as -mcpu=cortex-m3 -mthumb blink.s -o blink.o
	arm-none-eabi-ld -T stm32.ld blink.o -o blink.elf
	arm-none-eabi-objcopy blink.elf -O binary blink.bin
