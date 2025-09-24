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
.equ RCC_CFGR,		0x40021004

.section .isr_vector,"a",%progbits
.word _estack
.word reset+1

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
	orr r1, r1, #(1<<16) @ enable HSE
	str r1, [r0]

waitHSE:
	ldr r1, [r0]
	tst r1, #(1<<17)
	beq waitHSE

	@ Set all clock config
	ldr r0, =RCC_CFGR
	ldr r1, [r0]
	bic r1, r1, #(0xf<<18) @ clear PLLMUL
	orr r1, r1, #(7<<18) @ PLLMUL x9, so SYSCLK is now 72MHz
	orr r1, r1, #(1<<16) @ PLLSRC set to HSE
	bic r1, r1, #(1<<17) @ PLLXTPRE don't divide HSE by 2
	orr r1, r1, #(4<<8 ) @ APB1 /2 to limit PCLK1 to 36MHz
	bic r1, r1, #(8<<4 ) @ AHB /1
	bic r1, r1, #(4<<11) @ APB2 /1
	orr r1, r1, #(2<<14) @ ADC /6 = 12MHz
	str r1, [r0]

	@ Enable PLL
	ldr r0, =RCC_CR
	ldr r1, [r0]
	orr r1, r1, #(1<<24) @ enable PLL
	str r1, [r0]

waitPLL:
	ldr r1, [r0]
	tst r1, #(1<<25)
	beq waitPLL

	@ Set all clock config
	ldr r0, =RCC_CFGR
	bic r1, r1, #(3<<0 ) @ clear SW
	orr r1, r1, #(2<<0 ) @ SW set to use PLL
	str r1, [r0]

waitSW:
	ldr r1, [r0]
	and r2, r1, #(3<<2)
	cmp r2, #(2<<2)
	bne waitSW

	
	@ Configure PB9 as input with pull-down
	ldr r0, =GPIOB_CRH
	movs r1, #(0x1 << 7)
	str r1, [r0]

	ldr r0, =GPIOB_ODR
	ldr r1, [r0]
	bic r1, r1, #(0x1 << 8)
	str r1, [r0]

toggleLED:
	ldr r0, =GPIOC_ODR
	ldr r1, [r0]
	eor r1, #(1<<13)
	str r1, [r0]

	bl delay_500ms
	bl delay_500ms
	bl delay_500ms
	bl delay_500ms
	b toggleLED

.equ SYST_CSR, 0xE000E010
.equ SYST_RVR, 0xE000E014
.equ SYST_CVR, 0xE000E018

delay_500ms:
	ldr r0, =SYST_RVR
	ldr r1, =36000000-1
	str r1, [r0]

	ldr r0, =SYST_CVR
	movs r1, #0
	str r1, [r0]

	ldr r0, =SYST_CSR
	movs r1, #5
	str r1, [r0]

wait_flag:
	ldr r1, [r0]
	tst r1, #(1<<16)
	beq wait_flag

	bx lr
