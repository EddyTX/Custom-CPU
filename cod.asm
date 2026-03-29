; Program that makes an LED move left-right across the 8 LEDs of the FPGA, with a speed controlled by a delay.
START:
    LDI R2, 253      ; 0xFD - Hardware address of the LEDs
    LDI R5, 1        ; Constant 1 (used for subtractions)
    LDI R1, 1        ; Initial pattern (0000 0001)

;  Move to the left
LEFT_LOOP:
    STORE R1, R2     ; Display on LEDs (Write R1 to the address in R2)

    ; Left delay (a loop that subtracts some values to create a visible delay)
    LDI R3, 255
D1:
    LDI R4, 255
D2:
    LDI R6, 4       ; Number indicating speed (higher = slower)
D3:
    SUB R6, R6, R5
    JMPZ D3_DONE
    JMP D3
D3_DONE:
    SUB R4, R4, R5
    JMPZ D2_DONE
    JMP D2
D2_DONE:
    SUB R3, R3, R5
    JMPZ L_DELAY_DONE
    JMP D1
L_DELAY_DONE:

    ; Check left edge (if R1 is 0x80, it means we reached the left edge)
    LDI R7, 128      ; 0x80 (1000 0000)
    SUB R0, R1, R7   ; R1 - 128. If it's 0, the program jumps
    JMPZ GO_RIGHT    ; If it hit the left edge, change direction

    ; Shift left (R1 << 1)
    ADD R1, R1, R1   ; Shift left by 1 (could also use SHL R1, R1, 1)
    JMP LEFT_LOOP    ; Repeat

; Move to the right
GO_RIGHT:
    STORE R1, R2     ; Display on LEDs

    ; Right delay (same logic as the left one)
    LDI R3, 255
D4:
    LDI R4, 255
D5:
    LDI R6, 4       ; Same value for speed
D6:
    SUB R6, R6, R5
    JMPZ D6_DONE
    JMP D6
D6_DONE:
    SUB R4, R4, R5
    JMPZ D5_DONE
    JMP D5
D5_DONE:
    SUB R3, R3, R5
    JMPZ R_DELAY_DONE
    JMP D4
R_DELAY_DONE:

    ; Check right edge (if R1 is 0x01, it means we reached the right edge)
    LDI R7, 1
    SUB R0, R1, R7
    JMPZ START       ; If it hit the initial edge, we start over to the left!

    ; --- SHIFT RIGHT ---
    SHR R1, R1, R5   ; Logical shift to the right
    JMP GO_RIGHT     ; Repeat
