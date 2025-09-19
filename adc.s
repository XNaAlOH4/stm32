.syntax unified
.cpu cortex-m3
.thumb

.global reset

.equ _estack,		0x20005000

.equ RCC_APB2ENR,	0x40021018
.equ GPIOC_CRH,		0x40011004
.equ GPIOB_CRH,		0x40010C04
.equ GPIOC_ODR,		0x4001100C
.equ GPIOB_ODR,		0x40010C0C
.equ GPIOB_IDR,		0x40010C08

.equ RCC_CR,		0x40021000

.section .isr_vector,"a",%progbits
.word _estack
.word reset

.section .text
reset:
	@ Initialise stack pointer already done by hardware on reset
	@ enable clock for GPIOC

	@ Reset and Clock Controller(RCC) Advanced Peripheral Bus(APB)2 (Peripheral Clock Enable Register)ENR
	ldr r0, =RCC_APB2ENR
	ldr r1, [r0]
	orr r1, r1, #(3<<3) @ enable IOPC EN (bit 4) & IOPB EN (bit 3)
	str r1,[r0]

	@ Configure PC13 as output push-pull, 2MHz
	ldr r0, =GPIOC_CRH
	@ set mode > 0 and cnf = 0 to set general purpose push-pull
	@ mode; 00 input, 01 output 10MHz, 10 2MHz, 11 50MHz
	movs r1,#(0x1 << 20)
	str r1,[r0]

	@ Enable HSE
	ldr r0, =RCC_CR
	ldr r1, [r0]
	orr r1, #(1<<16) @ enable HSE
	str r1, [r0]
	
	movs r2, #0x20
wait: @ wait for 6 cycles of HSE to check if it is stable
	subs r2, #1
	bne wait

	ldr r1, [r0]
	and r2, r1, #(1<<17) @ Check if HSE Enabled
	bne stop

	@ Configure PB9 as input with pull-down
	ldr r0, =GPIOB_CRH
	movs r1, #(0x1 << 7)
	str r1, [r0]

	ldr r0, =GPIOB_ODR
	ldr r1, [r0]
	bic r1, r1, #(0x1 << 8)
	str r1, [r0]

toggleLED:
	ldr r0, =GPIOB_IDR
	ldr r1, [r0]
	and r2, r1, #(1<<9)
	lsl r1, r2, #4
	ldr r0, =GPIOC_ODR
	str r1, [r0]

	movs r2, #0x20
	lsls r2, r2, #15

delay:
	subs r2, #1
	bne delay

	b toggleLED

stop:
	ldr r0, =GPIOC_ODR
	ldr r1, [r0]
	eor r1, #(1<<13)
	str r1, [r0]
stop_actual:
	b stop_actual
