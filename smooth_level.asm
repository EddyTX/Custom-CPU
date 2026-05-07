; ==============================================================
; NIVELA DIGITALA "SMOOTH" (Culisare pe toate cele 8 LED-uri)
; ==============================================================

; --- 1. CONFIGURARE ADXL345 ---
LDI R1, 0xB1     ; Adresa DATA_FORMAT
LDI R2, 0x40     ; Setam 3-Wire SPI
STORE R2, R1

LDI R1, 0xAD     ; Adresa POWER_CTL
LDI R2, 0x08     ; Measure Mode
STORE R2, R1

; --- 2. PREGATIRE CONSTANTE ---
LDI R3, 0xB2     ; R3 = Adresa DATAX0 (Folosim doar byte-ul asta pt unghiuri blande)
LDI R4, 0xFD     ; R4 = Adresa LED-urilor
LDI R5, 128      ; R5 = Offset-ul magic pentru liniarizare
LDI R15, 1       ; R15 = Constanta '1' pt Shiftari si Scaderi

; ==============================================================
; --- 3. BUCLA PRINCIPALA ---
BUCLA_CITIRE:
LOAD R6, R3      ; R6 = Citim acceleratia pe axa X 

; PASUL A: Transformam din [-128, 127] in [0, 255]
ADD R6, R6, R5   

; PASUL B: Impartim la 32 (Shift Right de 5 ori) pt a obtine Index (0 - 7)
SHR R6, R6, R15
SHR R6, R6, R15
SHR R6, R6, R15
SHR R6, R6, R15
SHR R6, R6, R15

; PASUL C: Pregatim Masca de LED (Pornim cu extremitatea stanga)
LDI R7, 128      ; R7 = 1000_0000 (Punctul luminos la LED 7)

; PASUL D: Culisam punctul luminos in functie de Indexul din R6
SHIFT_LOOP:
; Verificam daca indexul R6 a ajuns la 0. (Folosim un AND cu el insusi ca sa setam Zero Flag-ul)
AND R8, R6, R6   
JMPZ AFISARE     ; Daca R6 e 0, gata, am pus punctul unde trebuie!

SHR R7, R7, R15  ; Mutam punctul luminos o pozitie la dreapta (R7 >> 1)
SUB R6, R6, R15  ; Scadem 1 din Index (R6 = R6 - 1)
JMP SHIFT_LOOP   ; Ne intoarcem in bucla

; PASUL E: Aprindem LED-ul
AFISARE:
STORE R7, R4     ; Scoatem Masca calculata pe pinii fizici
JMP BUCLA_CITIRE ; Repetam tot procesul la infinit!