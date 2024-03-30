    ; Project 1
    ; Author: Rohan Malipeddi
    ; Date: 03/14/2024
    ; Description: Program to toggle blinking red LED, Additional feature: to switch between different LEDs
    ; Last-revised: 03/17/24

    .thumb          ; 16-bit instruction set
    .global main    ; export main symbol so it is recognized by other source files

    .text       ; what follows goes in CODE region of memory map

switch1Init         ; initialization function for S1 pin
	PUSH    {R0, R1}
    MOV     R0, #0
    LDR     R1, P1SEL0_1    ; set function of pin P1.1 to GPIO
    STRB    R0, [R1]
    LDR     R1, P1SEL1_1
    STRB    R0, [R1]
    LDR     R1, P1DIR_1     ; set direction of P1.1 to input
    STRB    R0, [R1]
    ORR     R0, R0, #0x01   ; set lsb of R0
    LDR     R1, P1OUT_1     ; set internal R of P1.1 for pull-up
    STRB    R0, [R1]
    LDR     R1, P1REN_1     ; enable internal R of P1.1
    STRB    R0, [R1]
    POP     {R0, R1}
    BX      LR
; end switch1Init

switch2Init			; initialization function for S2 pin
	PUSH    {R0, R1}
    MOV     R0, #0
    LDR     R1, P1SEL0_4    ; set function of pin P1.4 to GPIO
    STRB    R0, [R1]
    LDR     R1, P1SEL1_4
    STRB    R0, [R1]
    LDR     R1, P1DIR_4     ; set direction of P1.4 to input
    STRB    R0, [R1]
    ORR     R0, R0, #0x01   ; set lsb of R0
    LDR     R1, P1OUT_4     ; set internal R of P1.4 for pull-up
    STRB    R0, [R1]
    LDR     R1, P1REN_4     ; enable internal R of P1.4
    STRB    R0, [R1]
    POP     {R0, R1}
    BX      LR
; end switch2Init


led2Init            ; initialization function for LED2 pins
    PUSH    {R4, R5}		; Push R4 and R5 to stack to save them
      ; set function of pin P2.0 to GPIO
    MOV 	R4, #0
    LDR     R5, P2SEL0_0      ; Load address P2SEL0 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL0 to clear its bit 0
    LDR     R5, P2SEL1_0	  ; Load address P2SEL1 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL1 to clear its bit 0
      ; set direction of P2.0 to output
    LDR     R5, P2DIR_0       ; Load address P2DIR to R5
    ORR     R4, R4, #0x01	  ; Set Bit 0 of R0 to be "1"
    STRB    R4, [R5]		  ; Store R0 to [P1DIR] to set direction of P2.0 to output

    ; set function of pin P2.1 to GPIO
    MOV 	R4, #0
    LDR     R5, P2SEL0_1      ; Load address P2SEL0 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL0 to clear its bit 1
    LDR     R5, P2SEL1_1	  ; Load address P2SEL1 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL1 to clear its bit 1
      ; set direction of P2.1 to output
    LDR     R5, P2DIR_1       ; Load address P2DIR to R5
    ORR     R4, R4, #0x01	  ; Set Bit 1 of R0 to be "1"
    STRB    R4, [R5]		  ; Store R0 to [P1DIR] to set direction of P2.1 to output

    ; set function of pin P2.2 to GPIO
    MOV 	R4, #0
    LDR     R5, P2SEL0_2      ; Load address P2SEL0 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL0 to clear its bit 2
    LDR     R5, P2SEL1_2	  ; Load address P2SEL1 to R5
    STRB    R4, [R5]		  ; Store R4 to P2SEL1 to clear its bit 2
      ; set direction of P2.2 to output
    LDR     R5, P2DIR_2       ; Load address P2DIR to R5
    ORR     R4, R4, #0x01	  ; Set Bit 2 of R0 to be "1"
    STRB    R4, [R5]		  ; Store R0 to [P1DIR] to set direction of P2.2 to output

    POP     {R4, R5}		  ; Pop R0 and R1 on stack to restore them
    BX      LR				  ; Return to caller

; end led2Init

main                ; starting point of program
	NOP
    ; call init functions
	BL		led2Init
	BL		switch1Init
	BL 		switch2Init
    ; set initial LED2 output
	LDR     R3, P1IN_1      ; R3 will hold address for switch 1 input
	LDR		R7, P1IN_4		; R7 will hold address for switch 2 input
    LDR     R5, P2OUT_0		; Load address P1OUT, output port of Port1
    LDRB    R4, [R5]        ; retrieve value of Port1 Output register
    MOV		R4, #0x0
    STRB	R4, [R5]
    ADD		R5, R5, #4
    STRB	R4, [R5]
    ADD		R5, R5, #4
    STRB	R4, [R5]
    LDR		R5, P2OUT_0
    MOV		R8, #0x8068
	MOVT	R8, #0x4209
toggleLoop
    ; wait for S1 pressed
	LDRB    R6, [R3]        ; get value of switch input
    TST     R6, #0x01       ; test if bit 0 is set (SW == 1)
    BNE     toggleLoop      ; keep checking if not pressed (SW == 1)
    ; delay 5 ms
    MOV		R2, #0x1388
delay                       ; delay by decrementing register until it is 0
    SUBS    R2, #0x01
    BNE     delay
    ; wait for S1 released
release
    LDRB    R6, [R3]        ; get value of switch input
    TST     R6, #0x01       ; test if bit 0 is set (SW == 1)
    BEQ     release         ; keep checking while pressed (SW == 0)
    ; delay 5 ms
	MOV		R2, #0x1388
delay1                       ; delay by decrementing register until it is 0
    SUBS    R2, #0x01
    BNE     delay1
blinkLoop
    ; toggle LDE and load counter for 500 ms
    EOR     R4, R4, #0x01   ; toggle P1.0 output value
    MOV		R0, #0x0
    STRB    R4, [R5]
    MOV     R2, #0x24F8
    MOVT    R2, #0x1

checkS1
    ; check S1 state - jump to stopBlink if pressed
    LDRB    R6, [R3]        ; get value of switch input
	TST     R6, #0x01       ; test if bit 0 is set (SW == 1)
    BEQ     stopBlink      ; keep checking if not pressed (SW == 1)

    ; check S2 state - jump to toggleLED if pressed
   	CMP		R4, R0
   	BEQ		exit			; if(R4 == 0) exit
	LDRB    R6, [R7]        ; get value of switch input
	TST     R6, #0x01       ; test if bit 0 is set (SW == 1), flag is set to zero
    BEQ     toggleLED      	; keep checking if not pressed (SW == 1), check if 0


exit
    ; decrement counter
    SUBS    R2, #0x01

    ;if counter == 0 - jump to blinkLoop, otherwise jump to checkS1
    BNE     checkS1
    B		blinkLoop

; end checkS1
; end blinkLoop

toggleLED 	;TODO
	MOV		R4, #0x0
	STRB	R4, [R5]
	EOR		R4, R4, #0x01

	CMP		R5, R8 			; sets the zero status flag to 1 if equal
	BNE		then			; if(R5 != R8) go to then
	SUB		R5, R5, #8
	STRB	R4, [R5]
release5
	LDRB	R6, [R7]
	TST		R6, #0x01
	BEQ		release5
	B		exit

then
	ADD		R5, R5, #4
	STRB	R4, [R5]
release4
	LDRB	R6, [R7]
	TST		R6, #0x01
	BEQ		release4
	B		exit

stopBlink
    ; turn off LED2
	MOV 	R4, #0x0
	STRB 	R4, [R5]
    ; delay 5 ms
	MOV		R2, #0x1388
delay3                       ; delay by decrementing register until it is 0
    SUBS    R2, #0x01
    BNE     delay3
    ; wait for S1 released
release2
    LDRB    R6, [R3]        ; get value of switch input
    TST     R6, #0x01       ; test if bit 0 is set (SW == 1)
    BEQ     release2         ; keep checking while pressed (SW == 0)
    ; delay 5 ms
	MOV		R2, #0x1388
delay4                       ; delay by decrementing register until it is 0
    SUBS    R2, #0x01
    BNE     delay4
    ; jump to toggleLoop start

	B 		toggleLoop
; end toggleLoop
; end main


    .align 4
    ; store addresses for peripheral registers and link to descriptive symbol here
;  offset addresses obtained from Table 6-21 of data sheet
; following addresses are for button S1 - PIN1.1
P1SEL0_1    .word    0x42098144    ; 0x42000000 + 32*0x4C0A + 4*0x1
P1SEL1_1    .word    0x42098184    ; 0x42000000 + 32*0x4C0C + 4*0x1
P1DIR_1     .word    0x42098084    ; 0x42000000 + 32*0x4C04 + 4*0x1
P1OUT_1     .word    0x42098044    ; 0x42000000 + 32*0x4C02 + 4*0x1
P1IN_1      .word    0x42098004    ; 0x42000000 + 32*0x4C00 + 4*0x1
P1REN_1     .word    0x420980C4    ; 0x42000000 + 32*0x4C06 + 4*0x1
; following addresses are for button S2 - PIN1.4
P1SEL0_4    .word    0x42098150    ; 0x42000000 + 32*0x4C0A + 4*0x4
P1SEL1_4    .word    0x42098190    ; 0x42000000 + 32*0x4C0C + 4*0x4
P1DIR_4     .word    0x42098090    ; 0x42000000 + 32*0x4C04 + 4*0x4
P1OUT_4     .word    0x42098050    ; 0x42000000 + 32*0x4C02 + 4*0x4
P1IN_4      .word    0x42098010    ; 0x42000000 + 32*0x4C00 + 4*0x4
P1REN_4     .word    0x420980D0    ; 0x42000000 + 32*0x4C06 + 4*0x4
; following addresses are for red LED2 - PIN 2.0
P2SEL0_0  .field  0x42098160, 32   ; 0x42000000 + 32*0x4C0B + 4*0x0
P2SEL1_0  .field  0x420981A0, 32   ; 0x42000000 + 32*0x4C0D + 4*0x0
P2DIR_0   .field  0x420980A0, 32   ; 0x42000000 + 32*0x4C05 + 4*0x0
P2OUT_0   .field  0x42098060, 32   ; 0x42000000 + 32*0x4C03 + 4*0x0
; following addresses are for green LED2 - PIN2.1
P2SEL0_1  .field  0x42098164, 32   ; 0x42000000 + 32*0x4C0B + 4*0x1
P2SEL1_1  .field  0x420981A4, 32   ; 0x42000000 + 32*0x4C0D + 4*0x1
P2DIR_1   .field  0x420980A4, 32   ; 0x42000000 + 32*0x4C05 + 4*0x1
P2OUT_1   .field  0x42098064, 32   ; 0x42000000 + 32*0x4C03 + 4*0x1
; following addresses are for blue LED2 - PIN2.2
P2SEL0_2  .field  0x42098168, 32   ; 0x42000000 + 32*0x4C0B + 4*0x2
P2SEL1_2  .field  0x420981A8, 32   ; 0x42000000 + 32*0x4C0D + 4*0x2
P2DIR_2   .field  0x420980A8, 32   ; 0x42000000 + 32*0x4C05 + 4*0x2
P2OUT_2   .field  0x42098068, 32   ; 0x42000000 + 32*0x4C03 + 4*0x2

    .end
