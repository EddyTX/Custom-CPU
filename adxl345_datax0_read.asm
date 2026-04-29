; ==============================================================
; ETAPA 2: Testare SPI si LED-uri
; ==============================================================

; --- 1. CONFIGURARE ADXL345 (DATA_FORMAT) ---
; Vrem modul 3-Wire SPI (Bit 6 = 1). Adresa: 0x80 | 0x31 = 0xB1
LDI R1, 0xB1
LDI R2, 0x40     ; 0x40 il obliga sa raspunda pe SDI
STORE R2, R1     ; Trimitem pe SPI

; --- 2. PORNIRE SENZOR (POWER_CTL) ---
; Scoatem senzorul din Standby. Adresa: 0x80 | 0x2D = 0xAD
LDI R3, 0xAD
LDI R4, 0x08     ; Bitul 3 e 'Measure Mode'
STORE R4, R3     ; Trimitem pe SPI

; --- 3. PREGATIREA REGISTRILOR PENTRU BUCLA ---
LDI R5, 0xB2     ; Adresa SPI pentru axa X (DATAX0 -> LSB)
LDI R6, 0xFD     ; Adresa portului GPIO pentru LED-uri

; --- 4. BUCLA DE CITIRE (INFINITA) ---
CITIRE:
LOAD R7, R5      ; Citim valoarea de la senzor in R7
STORE R7, R6     ; Aruncam valoarea direct pe LED-uri
JMP CITIRE