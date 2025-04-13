
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb



.section .text
.global main

.equ GPIOB_ODR, 0x40010C0C  @ GPIOB Output Data Register (ODR)
.equ RCC_APB2ENR, 0x40021018 @ RCC APB2 peripheral clock enable register
.equ GPIOB_CRH, 0x40010C04   @ GPIOB Config Register High

main:
    LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	ORR R1, R1, #(1 << 3)     @ Enable GPIOB clock
	STR R1, [R0]
	LDR R1, [R0]              @ Read back to check


    @ Configure PB8 & PB9 in CRH
	LDR R0, =GPIOB_CRH
	LDR R1, [R0]
	BIC R1, R1, #(0xFF << 0)  @ Clear PB8 & PB9 config (bits 0-7)
	ORR R1, R1, #(0x33 << 0)  @ Set PB8 & PB9 as Output 50MHz
	STR R1, [R0]

	@ Configure PB6 & PB7 in CRL
	LDR R0, =0x40010C00  @ GPIOB_CRL (for PB6 & PB7)
	LDR R1, [R0]
	BIC R1, R1, #(0xFF << 24)  @ Clear PB6 & PB7 config (bits 24-31)
	ORR R1, R1, #(0x33 << 24)  @ Set PB6 & PB7 as Output 50MHz
	STR R1, [R0]


loop:
    @ Set GPIOB Pins 9 & 7 HIGH, 8 & 6 LOW
    LDR R0, =GPIOB_ODR
    LDR R1, [R0]              @ Read current GPIOB state
    BIC R1, R1, #((1<<6) | (1<<8))   @ Clear PB6 and PB8
    ORR R1, R1, #((1<<9) | (1<<7))   @ Set PB9 and PB7
    STR R1, [R0]              @ Write back to ODR
    BL delay_300ms

    @ Set GPIOB Pins 9 & 7 LOW, 8 & 6 HIGH
    LDR R1, [R0]              @ Read current GPIOB state
    BIC R1, R1, #((1<<9) | (1<<7))   @ Clear PB9 and PB7
    ORR R1, R1, #((1<<8) | (1<<6))   @ Set PB8 and PB6
    STR R1, [R0]              @ Write back to ODR
    BL delay_300ms

    B loop  @ Repeat forever

delay_300ms:
    LDR R2, =2400000   @ Adjust based on system clock (Assuming 8MHz)
delay_loop:
    SUBS R2, R2, #1
    BNE delay_loop
    BX LR
