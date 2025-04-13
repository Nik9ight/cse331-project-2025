.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb
.section .text
.global main

.equ GPIOC_ODR, 0x4001100C    @ GPIOC Output Data Register (ODR) address
.equ RCC_APB2ENR, 0x40021018  @ RCC APB2 peripheral clock enable register
.equ GPIOC_CRH, 0x40011004    @ GPIOC Config register high

main:
    @ Enable GPIOC clock
    LDR R0, =RCC_APB2ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 4)     @ Enable GPIOC clock (bit 4)
    STR R1, [R0]

    @ Configure PC13 as output (push-pull, max speed 2 MHz)
    LDR R0, =GPIOC_CRH
    LDR R1, [R0]
    BIC R1, R1, #0xF00000      @ Clear bits 23:20 (CNF13 and MODE13)
    ORR R1, R1, #0x200000      @ Set MODE13 to 0x2 (Output mode, max speed 2 MHz)
    STR R1, [R0]

loop:
    @ Turn on the LED (set PC13 LOW)
    LDR R0, =GPIOC_ODR
    LDR R1, [R0]
    BIC R1, R1, #(1 << 13)     @ Clear bit 13 (PC13 LOW)
    STR R1, [R0]
    BL delay_300ms              @ Call delay function

    @ Turn off the LED (set PC13 HIGH)
    LDR R0, =GPIOC_ODR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 13)     @ Set bit 13 (PC13 HIGH)
    STR R1, [R0]
    BL delay_300ms              @ Call delay function

    B loop  @ Repeat forever

delay_300ms:
    LDR R2, =2400000   @ Delay for 300ms at 8MHz (adjust for other clock speeds)
delay_loop:
    SUBS R2, R2, #1
    BNE delay_loop
    BX LR
