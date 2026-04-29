; ==============================================================
; BENCHMARK SUPREM: Secventa Fibonacci (TRIPLE DELAY)
; ==============================================================

; --- 1. INITIALIZARE CONSTANTE ---
LDI R1, 0xFD     ; Adresa LED-urilor
LDI R15, 1       ; Constanta 1
LDI R0, 0        ; Constanta 0

RESET:
LDI R2, 0        ; A = 0
LDI R3, 1        ; B = 1

MAIN_LOOP:
STORE R2, R1     ; Afiseaza numarul

; --- 2. TRIPLE DELAY (Asteptam ~0.4 secunde) ---
LDI R7, 50       ; Bucla 3 (Cea mai lenta)
LOOP_3:
LDI R5, 255      ; Bucla 2
OUTER_LOOP:
LDI R6, 255      ; Bucla 1 (Cea mai rapida)
INNER_LOOP:
SUB R6, R6, R15
JMPZ INNER_DONE
JMP INNER_LOOP
INNER_DONE:
SUB R5, R5, R15
JMPZ OUTER_DONE
JMP OUTER_LOOP
OUTER_DONE:
SUB R7, R7, R15
JMPZ LOOP_3_DONE
JMP LOOP_3
LOOP_3_DONE:

; --- 3. CALCULUL URMATORULUI NUMAR ---
ADD R4, R2, R3   ; C = A + B
ADD R2, R3, R0   ; A = B
ADD R3, R4, R0   ; B = C

; --- 4. CONDITIA DE RESET ---
LDI R14, 233
SUB R13, R2, R14
JMPZ RESET

JMP MAIN_LOOP