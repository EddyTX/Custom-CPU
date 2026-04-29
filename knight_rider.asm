; Program care face un LED sa se plimbe stanga-dreapta pe cele 8 led-uri alea FPGA-ului, cu o viteza controlata de un delay.
START:
    LDI R2, 253      ; 0xFD - Adresa hardware a LED-urilor
    LDI R5, 1        ; Constanta 1 (folosita la scaderi)
    LDI R1, 1        ; Pattern-ul initial (0000 0001)

;  Muta spre stanga
LEFT_LOOP:
    STORE R1, R2     ; Afiseaza pe LED-uri (Scrie R1 la adresa din R2)

    ; Delay stanga (un loop care scade niste valori pentru a crea o intarziere vizibila)
    LDI R3, 255
D1:
    LDI R4, 255
D2:
    LDI R6, 4       ; Numar care indica viteza (mai mare = mai lent)
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

    ; Verifica marginea stanga (daca R1 e 0x80, inseamna ca am ajuns la marginea stanga)
    LDI R7, 128      ; 0x80 (1000 0000)
    SUB R0, R1, R7   ; R1 - 128. Daca e 0, se face jump-ul
    JMPZ GO_RIGHT    ; Daca a lovit marginea stanga, schimba sensul

    ; Shift stanga (R1 << 1)
    ADD R1, R1, R1   ; Shift left cu 1 (se putea folosi si SHL R1, R1, 1)
    JMP LEFT_LOOP    ; Repeta

; Muta spre dreapta
GO_RIGHT:
    STORE R1, R2     ; Afiseaza pe LED-uri

    ; Delay dreapta (aceeasi logica ca la stanga)
    LDI R3, 255
D4:
    LDI R4, 255
D5:
    LDI R6, 4       ; Aceeasi valoare pentru viteza
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

    ; Verifica marginea dreapta (daca R1 e 0x01, inseamna ca am ajuns la marginea dreapta)
    LDI R7, 1
    SUB R0, R1, R7
    JMPZ START       ; Daca a lovit marginea initiala, o luam de la capat in stanga!

    ; --- SHIFT DREAPTA ---
    SHR R1, R1, R5   ; Shiftam logic la dreapta
    JMP GO_RIGHT     ; Repeta