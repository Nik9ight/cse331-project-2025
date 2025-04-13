.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.section .text
.global main

//.equ CONTROL_REG, 0x20000000  @ Example address for CONTROL_REG (replace with actual address)
.equ GPIOB_ODR, 0x40010C0C    @ GPIOB Output Data Register (ODR) address
.equ RCC_APB2ENR, 0x40021018  @ RCC APB2 peripheral clock enable register
.equ GPIOB_CRL, 0x40010C00    @ GPIOB Config register low (for pins 0-7)
.equ GPIOB_CRH, 0x40010C04    @ GPIOB Config register high (for pins 8-15)

main:
    @ Enable GPIOB clock
    LDR R0, =RCC_APB2ENR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 3)     @ Enable GPIOB clock (bit 3)
    STR R1, [R0]

    @ Configure PB6, PB7, PB8, PB9 as output (push-pull, max speed 2 MHz)
    LDR R0, =GPIOB_CRL
    LDR R1, [R0]
    BIC R1, R1, #0xFF000000    @ Clear bits for PB6 and PB7 (bits 24-31)
    ORR R1, R1, #0x33000000    @ Set PB6 and PB7 to output mode (bits 24-31)
    STR R1, [R0]

    LDR R0, =GPIOB_CRH
    LDR R1, [R0]
    BIC R1, R1, #0x000000FF    @ Clear bits for PB8 and PB9 (bits 0-7)
    ORR R1, R1, #0x00000033    @ Set PB8 and PB9 to output mode (bits 0-7)
    STR R1, [R0]

    @ Turn on all LEDs initially (set PB6-PB9 HIGH)
    LDR R0, =GPIOB_ODR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 6 | 1 << 7 | 1 << 8 | 1 << 9)  @ Set PB6-PB9 HIGH
    STR R1, [R0]
    BL delay_300ms

    @ Load CONTROL_REG address
    LDR R0, =CONTROL_REG
    LDR R1, [R0]

    @ Task 1: Turn on the living room lights (bit 0) and the heating system (bit 2)
    MOV R2, #0x05              @ Load value 0x05 (binary 00000101) to set bit 0 and bit 2
    ORR R1, R1, R2

    @ Turn off LED for Task 1 (PB6 LOW)
    LDR R0, =GPIOB_ODR
    LDR R2, [R0]
    BIC R2, R2, #(1 << 6)      @ Clear bit 6 (PB6 LOW)
    STR R2, [R0]
    BL delay_300ms              @ Add a delay to visualize the LED

    @ Task 2: Turn off the air conditioning system (bit 3)
    MOV R2, #0x08              @ Load value 0x08 (binary 00001000) to clear bit 3
    BIC R1, R1, R2

    @ Turn off LED for Task 2 (PB7 LOW)
    LDR R0, =GPIOB_ODR
    LDR R2, [R0]
    BIC R2, R2, #(1 << 7)      @ Clear bit 7 (PB7 LOW)
    STR R2, [R0]
    BL delay_300ms              @ Add a delay to visualize the LED

    @ Task 3: Toggle the security alarm (bit 6)
    MOV R2, #0x40              @ Load value 0x40 (binary 01000000) to toggle bit 6
    EOR R1, R1, R2

    @ Turn off LED for Task 3 (PB8 LOW)
    LDR R0, =GPIOB_ODR
    LDR R2, [R0]
    BIC R2, R2, #(1 << 8)      @ Clear bit 8 (PB8 LOW)
    STR R2, [R0]
    BL delay_300ms              @ Add a delay to visualize the LED

    @ Task 4: Check if the garage door is open (bit 5) and close it if open
    MOV R2, #0x20              @ Load value 0x20 (binary 00100000) to test/clear bit 5
    AND R3, R1, R2
    CMP R3, #0
    BEQ skipGarageClose

    MOV R2, #0x20              @ Load value 0x20 (binary 00100000) to clear bit 5
    BIC R1, R1, R2
    STR R1, [R0]
    B END

skipGarageClose:
    @ Turn off LED for Task 4 (PB9 LOW)
    LDR R0, =GPIOB_ODR
    LDR R2, [R0]
    BIC R2, R2, #(1 << 9)      @ Clear bit 9 (PB9 LOW)
    STR R2, [R0]
    BL delay_300ms              @ Add a delay to visualize the LED

    @ Store the modified value back into CONTROL_REG
    LDR R0, =CONTROL_REG
    STR R1, [R0]
	B END



END:
	@ Turn on all LEDs (set PB6-PB9 HIGH)
    LDR R0, =GPIOB_ODR
    LDR R1, [R0]
    ORR R1, R1, #(1 << 6 | 1 << 7 | 1 << 8 | 1 << 9)  @ Set PB6-PB9 HIGH
    STR R1, [R0]  @ Infinite loop to keep the program running
    B .

delay_300ms:
    LDR R2, =2400000   @ Delay for 300ms at 8MHz (adjust for other clock speeds)
delay_loop:
    SUBS R2, R2, #1
    BNE delay_loop
    BX LR

.data
CONTROL_REG: .word 0b01110101  @ Example value for CONTROL_REG
