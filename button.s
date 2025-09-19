.syntax unified
.cpu cortex-m3
.thumb

.global reset

.equ _estack, 0x20005000

.section .isr_vector,"a",%progbits
.word _estack
.word reset

.section .text
reset:
	@ Initialise stack pointer already done by hardware on reset
	@ enable clock for GPIOC

	@ Reset and Clock Controller(RCC) Advanced Peripheral Bus(APB)2 (Peripheral Clock Enable Register)ENR
	ldr r0, =0x40021018 @RCC_APB2ENR
	ldr r1, [r0]
	orr r1, r1, #(3<<3) @ enable IOPC EN (bit 4) & IOPB EN (bit 3)
	str r1,[r0]

	@ Configure PC13 as output push-pull, 2MHz
	ldr r0, =0x40011004
	@ set mode > 0 and cnf = 0 to set general purpose push-pull
	@ mode; 00 input, 01 output 10MHz, 10 2MHz, 11 50MHz
	movs r1,#(0x1 << 20)
	str r1,[r0]

	@ Configure PB9 as input with pull-down
	ldr r0, =0x40010C04
	movs r1, #(0x1 << 7)
	str r1, [r0]

	ldr r0, =0x40010C0C
	ldr r1, [r0]
	bic r1, r1, #(0x1 << 8)
	str r1, [r0]

toggleLED:
	ldr r0, =0x40010C08
	ldr r1, [r0]
	and r2, r1, #(1<<9)
	lsl r1, r2, #4
	ldr r0, =0x4001100C
	str r1, [r0]

	movs r2, #0x20
	lsls r2, r2, #15

delay:
	subs r2, #1
	bne delay

	b toggleLED
