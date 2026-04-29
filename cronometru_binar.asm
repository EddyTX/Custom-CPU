; -------------------------------------------------------------
; CRONOMETRU BINAR DE PRECIZIE - BUGFIXED (RACE CONDITION RESOLVED)
; SW[0] - Start / Pauza
; SW[7] - Reset Instant la 0
; -------------------------------------------------------------

	JMP MAIN
	LDI R0 0			; Padding 

; =============================================================
; RUTINA DE TRATARE A INTRERUPERII (Bate o data pe secunda)
; Toata logica sta aici acum!
; =============================================================
ISR_TIMER:
	LOAD R10 R4			; Citim switch-urile
	
	; 1. VERIFICAM RESET-UL PRIMA DATA (SW7)
	AND R11 R10 R2		; R11 = SW & 128
	JMPZ CHECK_START	; Daca SW7 e JOS, trecem la urmatoarea verificare
	
	; --- DACA SW7 E SUS -> RESET ---
	LDI R5 0			; Resetam contorul la 0
	STORE R5 R3			; Afisam pe LED-uri
	RETI				; Iesim din intrerupere imediat!

CHECK_START:
	; 2. VERIFICAM START/PAUZA (SW0)
	AND R11 R10 R1		; R11 = SW & 1
	JMPZ END_ISR		; Daca SW0 e JOS, nu facem nimic, doar iesim

	; --- DACA SW0 E SUS -> NUMARAM ---
	ADD R5 R5 R1		; Adunam 1 la secunda
	STORE R5 R3			; Actualizam LED-urile

END_ISR:
	RETI				; Gata secunda!

; =============================================================
; PROGRAMUL PRINCIPAL
; =============================================================
MAIN:
	; --- INCARCARE CONSTANTE ---
	LDI R0 0			
	LDI R1 1			; Masca SW[0] / Increment
	LDI R2 128			; Masca SW[7] 
	LDI R3 253			; Adresa LED PORT
	LDI R4 251			; Adresa SWITCH PORT
	LDI R6 248			; Adresa TIMER HIGH
	LDI R7 249			; Adresa TIMER LOW

	; --- CONFIGURARE TIMER LA 1000 ms ---
	LDI R8 3			
	LDI R9 232			
	STORE R8 R6			
	STORE R9 R7			

	; --- INITIALIZARE ---
	LDI R5 0			
	STORE R5 R3			

; --- BUCLA DE SUPRAVEGHERE ---
LOOP:
	; Bucla infinita complet GOALA. Nu foloseste Zero Flag!
	; Asa ca Timer-ul il poate intrerupe oricand fara sa strice nimic.
	JMP LOOP