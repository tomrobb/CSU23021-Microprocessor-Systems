; Assignment 3: Tom Roberts


	area tcd,code,readonly
	export __main

__main

; Values corresponding to the GPIO1 
IO1PIN	EQU	0xE0028010
IO1DIR	EQU	0xE0028018

; Values corresponding to TIMER0
T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000
IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18
TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF


; VIC Stuff -- UM, Table 41
VIC			equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200
Timer0ChannelNumber	equ	4				; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5						; UM, Table 58
	
	
; User Mode (the mode we're using):
Mode_User	equ 0x10


  ;----------------------------
  ; Switching to user mode:
  
	msr CPSR_c, #Mode_User

  ;----------------------------
  ; Initialise Timer0
  
	ldr	r0,=T0			; looking at you, Timer 0!

	mov r1,#TimerCommandReset
	str r1,[r0,#TCR]

	mov r1,#TimerResetAllInterrupts
	str r1,[r0,#IR]

	ldr r1,=(14745600/1)-1 
	; ^ this is equal to 1 second if we were running on the real hardware
	; unfortunately, since we're running a simulation, this is not always the case :(
	str r1,[r0,#MR0]

	mov r1,#TimerModeResetAndInterrupt
	str r1,[r0,#MCR]

	mov r1,#TimerCommandRun
	str r1,[r0,#TCR]
  
  ;----------------------------
  ; Setting up the GPIO pins
  
	ldr r0,=IO1DIR
	mov r1,#0xFFFFFFFF			; setting all 32 pins to be outputs
	str r1,[r0]


  ;----------------------------
  ; Initialise the VIC

	ldr r0,=VIC

	ldr r1,=irqhan
	str r1,[r0,#VectAddr0]

	mov r1,#Timer0ChannelNumber + (1<<IRQslot_en)
	str r1,[r0,#VectCtrl0]
	
	mov r1, #Timer0Mask
	str r1,[r0,#IntEnable]

	mov r1,#0
	str r1,[r0,#VectAddr]


; ------------------------------------------
; Main Program

	; setup:
	mov r6, #0 ; Counter for hours
	mov r7, #0 ; Counter for minutes
  
	; The addresses in memory we will be using to store our data
	ldr r4, =time
	ldr r5, =0xE0028010
	
	; Setting the seconds counter to 0 initially
	str r6,[r4]



inf_Loop

	; Get the current number of seconds from memory
	ldr r8,[r4]

	; If seconds >60, add 1 to the minute counter
	subs r0, r8, #60
	blt sec_noAdd ; we don't add to the mins if seconds are <60
	mov r8, r0
	str r8, [r4] ; updating the value in memory
	add r7, r7, #1
sec_noAdd

	; If minutes >60, add 1 to the hour counter
	subs r0, r7, #60
	blt min_noAdd ; we don't add to the hours if mins are <60
	mov r7, r0
	add r6, r6, #1
min_noAdd

	; If the hours are over 24 hours, we reset the hour counter
	cmp r6, #24
	ble hour_noReset ; we don't reset the hours if they're <24 hours
	mov r6, #0
hour_noReset


	; Convert the hours to Binary Code Decimal (BCD)
	mov r0,r6
	bl divideBy10
	orr r0, r0, r1, lsl #4
	orr r9, r0, r9, lsl #8

	lsl r9, r9, #4
	orr r9, r9, #0xF ; adding the spacer ':' aka '1111'

	; Convert minutes to Binary Code Decimal (BCD)
	mov r0, r7
	bl divideBy10
	orr r0, r0, r1, lsl #4
	orr r9, r0, r9, lsl #8

	lsl r9, r9, #4
	orr r9, r9, #0xF ; adding the spacer ':' aka '1111'

	; Convert seconds to Binary Code Decimal (BCD)
	mov r0, r8
	bl divideBy10
	orr r0, r0, r1, lsl #4
	orr r9, r0, r9, lsl #8

	; Writing the new value to GPIO1 output
	str r9, [r5]

	; loop forever
	b inf_Loop
	
	
; End of Main Program.	

;------------------------- 


; Divide by 10 subroutine
;
; Since division is not implemented in ARM, we count how many times
; the divisor can be subtraced by 10 before the value becomes negative
;
; 	Parameters:
; 		r0 - The divisor
; 	Returns:
; 		r0 - The remainder, aka the negative value after the subtractions
; 		r1 - How many times 10 can be subtracted before the number goes negative
; 
divideBy10	  mov r1,#-1      
divideBy10_l	add r1,r1,#1    
	subs r0,r0,#10  
	bge divideBy10_l     
	add r0,r0,#10   
	bx lr           




; Interrupt Request Exception Handler
;
; Adds 1 to the time counter stored in memory. (quite simple)
;
irqhan

	; Save program state, adjusting LR for IRQs by subtracting 4
	sub lr,lr,#4
	stmfd sp!,{r0-r1,lr}

  ;this is the body of the interrupt handler
	ldr r0, =time
	ldr r1, [r0]
	add r1, r1, #1 ; adds 1 to the timer counter
	str r1, [r0] 

  ;this is where we stop the timer from making the interrupt request to the VIC
  ;i.e. we 'acknowledge' the interrupt
	ldr r0,=T0
	mov r1,#TimerResetTimer0Interrupt
	str r1,[r0,#IR]

	;here we stop the VIC from making the interrupt request to the CPU:
	ldr r0,=VIC
	mov r1,#0
	str r1,[r0,#VectAddr]

	; Restore registers, PC (from LR) and CPSR
	ldmfd sp!,{r0-r1,pc}^

	area tcddata,data,readwrite

time	space 4

	end
