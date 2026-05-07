; ==============================================================
; NIVELA DIGITALA (3 STARI: Stanga, Orizontal, Dreapta)
; ==============================================================

; --- 1. CONFIGURARE ADXL345 ---
LDI R1, 0xB1     ; Adresa DATA_FORMAT
LDI R2, 0x40     ; Setam 3-Wire SPI
STORE R2, R1

LDI R1, 0xAD     ; Adresa POWER_CTL
LDI R2, 0x08     ; Measure Mode
STORE R2, R1

; --- 2. PREGATIRE REGISTRI ADRESE ---
LDI R3, 0xB2     ; Adresa DATAX0 (Byte-ul inferior / LSB)
LDI R4, 0xB3     ; Adresa DATAX1 (Byte-ul superior / Semnul)
LDI R5, 0xFD     ; Adresa LED-urilor

; ==============================================================
; --- 3. BUCLA PRINCIPALA ---
BUCLA:
; PASUL A: Verificam daca e inclinat STANGA (Negativ)
LOAD R6, R4      ; Citim DATAX1
LDI R7, 128      ; Masca pentru bitul de semn (1000_0000 in binar)
AND R8, R6, R7   ; Izolam bitul de semn. Seteaza Zero Flag daca e pozitiv
JMPZ VERIFICA_DREAPTA

; -> Daca a ajuns aici, e STANGA (Negativ)
LDI R9, 128      ; Valoarea pentru LED-ul 7 (1000_0000)
STORE R9, R5     ; Aprindem doar LED 7
JMP BUCLA

VERIFICA_DREAPTA:
; PASUL B: Verificam daca e inclinat DREAPTA (Pozitiv si Mare)
LOAD R10, R3     ; Citim DATAX0 (pentru ca stim deja ca DATAX1 e pozitiv)
LDI R11, 224     ; Masca pt valori >= 32 (1110_0000 in binar)
AND R12, R10, R11; Verificam daca macar unul din bitii mari e 1
JMPZ ORIZONTAL   ; Daca toti bitii mari sunt 0, inseamna ca e aproape de zero

; -> Daca a ajuns aici, e DREAPTA (Pozitiv > 31)
LDI R9, 1        ; Valoarea pentru LED-ul 0 (0000_0001)
STORE R9, R5     ; Aprindem doar LED 0
JMP BUCLA

ORIZONTAL:
; PASUL C: Nu e nici mult stanga, nici mult dreapta
LDI R9, 24       ; Valoarea pentru LED-urile din centru (0001_1000 in binar)
STORE R9, R5     ; Aprindem LED 3 si 4
JMP BUCLA