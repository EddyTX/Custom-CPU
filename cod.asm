; Code for testing the hardware timer interrupt system
; This code will setup the timer to generate an interrupt every 1s, shifting
; the position of the LED to the right by one (starting from the left side)

; First instruction: Jump to main loop
	JMP MAIN
	LDI R0 0			; padding instruction so the ISR lands exactly at address 0x02

ISR_TIMER:
	SHR R5 R5 R7		; R5 = R5 >> R7 (R5 >> 1)
	JMPZ RESET_LED		; If the result is 0, we reset it
	
UPDATE_LED:
	STORE R5 R6			; update the led port with the new value
	RETI				; return from interrupt

RESET_LED:
	LDI R5 128			; 0x80 - reset led to the left position (10000000)
	JMP UPDATE_LED		; go back and update the port

MAIN:
	LDI R1 3			; 0x03
	LDI R2 232			; 0xE8
	; Final number = 0x03E8 == 1000 , so the timer has to count to 1000 
	LDI R3 252			; 0xFC - upper half of timer target register
	LDI R4 251			; 0xFB - lower half of timer target register
	LDI R7 1			; For shifting by 1 position
	STORE R1 R3
	STORE R2 R4

	; setup the initial led state
	LDI R5 128			; 0x80 - start with the leftmost led turned on
	LDI R6 253			; 0xFD - led controller port address
	STORE R5 R6			; turn on the led before entering the wait loop

LOOP:
	; infinite loop, wait for the timer interrupt to trigger
	JMP LOOP