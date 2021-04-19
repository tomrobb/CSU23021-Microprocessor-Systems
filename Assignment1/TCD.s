; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.


	area	tcd,code,readonly

	
		LDR	SP, =0x40000000
		
	export	__main
__main

;
; our main program goes here


; ----------------------------------------------------

; saving the starting address of memory in r10
	LDR		R10, =rSpace

; for 5 factorial
;
	MOV		R1, #0x00000005
	BL		fact
	;store the result in memory
	MOV		R2, R10			; R2 has the address at memory where the result will be stored
	STMIA 	R2, {R0-R1}					; store contents of R0-R1 to memory at address 0x40000000
	ADD		R10, #8
;	In decimal, 5! = 120, which in hexadecimal, is 0x78
;	Results:
;	- 0x78 (as a 64 bit integer) is stored in memory at 0x40000000
;	- C bit is not set, since no errors occurred


; ----------------------------------------------------


; for 14 factorial
;
	MOV		R1, #0x0000000E		
	BL		fact
	;store the result in memory
	MOV		R2, R10			; R2 has the address at memory where the result will be stored
	STMIA 	R2, {R0-R1}					; store contents of R0-R1 to memory at address 0x40000008
	ADD		R10, #8
;	In decimal, 14! = 87178291200, which in hexadecimal, is 0x144C3B2800
;	Results:
;	- 0x144C3B2800 is stored in memory at 0x40000008
;	- C bit is not set, since no errors occurred	
		

; ----------------------------------------------------


; for 20 factorial
;
	MOV		R1, #0x00000014		
	BL		fact
	;store the result in memory
	MOV		R2, R10			; R2 has the address at memory where the result will be stored
	STMIA 	R2, {R0-R1}					; store contents of R0-R1 to memory at address 0x40000008
	ADD		R10, #8
;	In decimal, 20! = 2432902008176640000, which in hexadecimal, is 0x21C3677C82B40000
;	Results:
;	- 0x21C3677C82B40000 is stored in memory at 0x40000010
;	- C bit is not set, since no errors occurred
	
	
; ----------------------------------------------------


; for 30 factorial
	MOV		R1, #0x0000001E		
	BL		fact
	;store the result in memory
	MOV		R2, R10			; R2 has the address at memory where the result will be stored
	STMIA 	R2, {R0-R1}					; store contents of R0-R1 to memory at address 0x40000010
	
;	In decimal, 20! = 265252859812191058636308480000000,
;		which in hexadecimal, is 0xD13F6370F96865DF5DD54000000, this can not be stored in 64 bits.
;	Results:
;	- the subroutine returns 0 in r0 and r1, since errors have occurred
;	- 0x0000000000000000 is stored in memory at 0x40000018
;	- C bit IS SET, since errors have occurred (the result is greater than 64 bits)


fin	b	fin


;
; 	Factorial subroutine
;	Parameters:
;	- R1		= The number we're getting the factorial of
;			
;	Returns:
;	- R0		= Result of the most sifnificant bits of N!
;	- R1		= Result of the least sifnificant bits of N!
;   
;	If there are no errors:	
;		- the C bit must be clear. (C = 0)
;
;	If any error occurs:
;		- the C bit of the CPSR must be set
;		- a result of 0 returned in R0 & R1
;	
fact
	; preparation before the loops
	MOV		R0, #0x00000000
	MOV		R3,	R1
	
	
loop
	; for simplicity, move {r1, r0} into [r5, r4}
	mov r5, r1   ;r5 <- r1 
	mov r4, r0   ;r4 <- r0 

	
	SUB R3, #1
	; (R2:3) = #0x0000000N-1 
	CMP R3, #2
	BLT noLoop
	
	; temporary for the big bits
	MOV		R8, R0				; big bits (if any) stored in R8, so the next calc doesnt affect it
	; lower significant bits
	UMULL	R1,R0, R5,R3    	; (R0;R1) = LowerPart * N-1
	MOV		R7, R0				; if higher bits are reached, we add it in the next instruction.
	
	; adding higher bits (always 0 before a big factorial calc)
	UMULL	R0,R6, R8, R3    	; (R6;r0) = Higher parts * N-1, with any excess going in to R6
	ADD		R0, R7				; adding the carry from smaller calculation
	ADD		R9, R6,R9			; if R9 != 0, then the number is bigger than 64bits
	MOV 	R7, #0x00000000
	MOV 	R8, #0x00000000
	
	B loop
	
noLoop

	CMP		R9, #0x00000001
	BLT		over
	; If the result has any overflow, (R9 > 0)
	; 	this would cause an error and the c bit will be set
	; 	since the C bit is already set when we reach here, we don't need to change
	; 	anything, as this is only for numbers greater than 64bits
	;
	;	If any error occurs, the C bit of the CPSR must be set and a result of 0 returned in R0 & R1.
	MOV		R0, #0x00000000			;result of 0
	MOV		R1, #0x00000000			;result of 0
	B 		over
	

over

	BX		LR				; branch/link back to main, with results in R0-R1

STOP	B	STOP




; "random access memory"
	area	tcdresult,data,readwrite	
rSpace		space	4 * 8 	; space for four 8 byte elements, for results


	
	
	end