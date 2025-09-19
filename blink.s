.syntax unified
.cpu cortex-m3
.thumb

.global reset

.equ _estack, 0x20005000

.section .isr_vector,"a",%progbits
.word _estack
.word reset + 1

.section .text
reset:
	@ Initialise stack pointer already done by hardware on reset
	@ enable clock for GPIOC

	@ Reset and Clock Controller(RCC) Advanced Peripheral Bus(APB)2 (Peripheral Clock Enable Register)ENR
	ldr r0, =0x40021018 @RCC_APB2ENR
	ldr r1, [r0]
	orr r1, r1, #(1<<4) @ enable IOPCEN (bit 4)
	str r1,[r0]

	@ Configure PC13 as output push-pull, 2MHz
	ldr r0, =0x40011004
	@ set mode > 0 and cnf = 0 to set general purpose push-pull
	movs r1,#(0x1 << 20)
	str r1,[r0]

toggleLED:
	ldr r0, =0x4001100C
	ldr r1, [r0]
	eor r1, r1, #(1<<13)
	str r1, [r0]

	movs r2, #0x20
	lsls r2, r2, #15

delay:
	subs r2, #1
	bne delay

	b toggleLED
