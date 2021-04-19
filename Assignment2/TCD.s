;  The program should monitor inputs on Pins 24 to 27 and should provide a response on 
;	Pins 23 to 16 as follows:
;
;  Pins 23 -- 16 should be treated as a 8-bit number "D" whose value is initially 0.
;	Pin 23 is the MSB, Pin 16 the LSB.
;
;  Pins 27 -- 24 should be treated as individual inputs, where a pin's value going from
;	1 to 0 is to be interpreted as a corresponding [imaginary] push-button being pressed
;	and the transition from 0 to 1 is is to be interpreted as the release of the button.
;	For example, if Button 23 is pressed and released, Pin 23's value will go from 1 to 0;
;	then, when Button 23 is released, the value of Pin 23 will return from 0 to 1.
;	You can click theses values in the emulator.
;
;  The program should do the following:
;	- Pressing Button 24 should add 1 to the value of D.
;	- Pressing Button 25 should subtract 1 from the value of D.
;	- Pressing Button 26 should shift the bits in D to the left by one bit position.
;	- Pressing Button 27 should shift the bits in D to the right by one bit position.
;
;	Tom Roberts - 19335276
;

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010		; guess
	
	; 
	; Main Program:
	;
	
	mov r0, #0		; starting with D=0
	
	; setting bits 23-16 to be outputs
	ldr r1, =IO1DIR
	mov r2, #0x00FF0000		; bits 23-16
	str	r2,[r1]				; set the outputs
	
	
infLoop

	; check if pin 24 is being pressed, if so, branch to add1 subroutine
	ldr	r4,=IO1PIN			; storing the value of the pins in r4
	ldr r4, [r4]
	mov r5, #0xFE000000	
	add r5, r5, r0, LSL #16	; adding D to account for bit difference
	cmp r5, r4				;
	beq add1
	
	; check if pin 25 is being pressed, if so, branch to sub1 subroutine
	ldr	r4,=IO1PIN			; storing the value of the pins in r4
	ldr r4, [r4]
	mov r5, #0xFD000000	
	add r5, r5, r0, LSL #16	; adding D to account for bit difference
	cmp r5, r4	
	beq sub1
	
	
	; check if pin 26 is being pressed, if so, branch to leftShift subroutine
	ldr	r4,=IO1PIN			; storing the value of the pins in r4
	ldr r4, [r4]
	mov r5, #0xFB000000	
	add r5, r5, r0, LSL #16	; adding D to account for bit difference
	cmp r5, r4			;
	beq shiftLeft
	
	
	; check if pin 27 is being pressed, if so, branch to rightShift subroutine
	ldr	r4,=IO1PIN			; storing the value of the pins in r4
	ldr r4, [r4]
	mov r5, #0xF7000000	
	add r5, r5, r0, LSL #16	; adding D to account for bit difference
	cmp r5, r4	
	beq shiftRight
	
	b infLoop
	
	
fin	b	fin

; ------------------------------------------------------ ;


add1
	; add1 subroutine=
	; Pressing Button 24 should add 1 to the value of D.
	;
stillPressed1	
	mov r4, #0xFF000000		; only continue if the button is unpressed
	add r4, r4, r0, LSL #16 ; adding D to account for bit difference
	ldr	r6,=IO1PIN
	ldr r6,[r6]
	cmp r6, r4				; only continue if the button is unpressed
	bne stillPressed1
	cmp r0, #0x000000FF		; skip the add if D is max size
	beq displayD
	add r0, r0, #1			; adding 1 to the value of D
	b displayD


; ------------------------------------------------------ ;


sub1
	; sub1 subroutine=
	; Pressing Button 25 should subtract 1 from the value of D.
	;
stillPressed2	
	mov r4, #0xFF000000		; only continue if the button is unpressed
	add r4, r4, r0, LSL #16 ; adding D to account for bit difference
	ldr	r6,=IO1PIN
	ldr r6,[r6]
	cmp r6, r4				; only continue if the button is unpressed
	bne stillPressed2
	cmp r0, #0				; dont subtract if D = 0
	beq displayD
	sub r0, r0, #1			; adding 1 to the value of D
	b displayD


; ------------------------------------------------------ ;


shiftLeft
	; shiftLeft subroutine=
	; Pressing Button 26 should shift the bits in D to the left by one bit position.
	;
stillPressed3	
	mov r4, #0xFF000000		; only continue if the button is unpressed
	add r4, r4, r0, LSL #16 ; adding D to account for bit difference
	ldr	r6,=IO1PIN
	ldr r6,[r6]
	cmp r6, r4				; only continue if the button is unpressed
	bne stillPressed3
	cmp r0, #128			;
	bge displayD			; skip the LSL if D is about to exceed 8 bits, aka if it's 2^7 or more in size
	lsl r0, #1				; r0<<1
	b displayD
	

; ------------------------------------------------------ ;


shiftRight
	; shiftRight subroutine=
	; Pressing Button 27 should shift the bits in D to the right by one bit position.
	;
stillPressed4	
	mov r4, #0xFF000000		; only continue if the button is unpressed
	add r4, r4, r0, LSL #16 ; adding D to account for bit difference
	ldr	r6,=IO1PIN
	ldr r6,[r6]
	cmp r6, r4				; only continue if the button is unpressed
	bne stillPressed4
	cmp r0, #1
	beq displayD
	lsr r0, #1				; r0>>1
	b displayD
	
	
; ------------------------------------------------------ ;	
	
	
displayD
	; displayD subroutine=
	; Displaying the value of D in the pins 23-16
	
	ldr r5, =IO1CLR
	mov r6, #0x00FF0000		; bits 23-16
	str	r6,[r5]				; clear the bits
	
	mov r3, r0				; moving the value of D into r3
	
	; LSL'ing by 16 bits, to make sure the output is in the right pins
	lsl r3, r3, #16
	ldr r7, =IO1SET			; 
	str	r3,[r7]				; setting bits
	
	; branch back to the infinite loop in main
	b infLoop



	end