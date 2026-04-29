; -------------------------------------------------------------
; INTERACTIVE "KNIGHT RIDER" LED SCANNER WITH SPEED CONTROL
; Opreste delay-ul din switch-uri pentru a schimba viteza
; -------------------------------------------------------------

    JMP MAIN
    LDI R0 0            ; Padding pentru ISR la adresa 0x02

; =============================================================
; RUTINA DE TRATARE A INTRERUPERII (ISR) - Ruleaza la fiecare Timer Tick
; =============================================================
ISR_TIMER:
    ; Verificam directia curenta (R7). 0 = Stanga, 1 = Dreapta.
    SUB R12 R7 R1       ; R12 = R7 - 1. (Daca R7 e 1, rezultatul e 0 -> Zero Flag = 1)
    JMPZ MOVE_RIGHT     ; Daca Z e 1, sarim la rutina de mutat dreapta

MOVE_LEFT:
    SHL R8 R8 R1        ; Shiftam valoarea LED-ului la stanga (R8 = R8 << 1)
    STORE R8 R3         ; Trimitem valoarea fizic pe portul de LED-uri
    
    ; Verificam daca ne-am lovit de marginea din stanga (LED-ul 8, adica 128 / 0x80)
    SUB R12 R8 R2       ; R12 = R8 - 128
    JMPZ CHG_DIR_R      ; Daca am ajuns la capat, schimbam directia
    RETI                ; Altfel, iesim din intrerupere

MOVE_RIGHT:
    SHR R8 R8 R1        ; Shiftam valoarea LED-ului la dreapta (R8 = R8 >> 1)
    STORE R8 R3         ; Trimitem valoarea fizic pe portul de LED-uri
    
    ; Verificam daca ne-am lovit de marginea din dreapta (LED-ul 1, adica 1 / 0x01)
    SUB R12 R8 R1       ; R12 = R8 - 1
    JMPZ CHG_DIR_L      ; Daca am ajuns la capat, schimbam directia
    RETI

CHG_DIR_R:
    LDI R7 1            ; Setam directia pe "Dreapta"
    RETI

CHG_DIR_L:
    LDI R7 0            ; Setam directia pe "Stanga"
    RETI

; =============================================================
; PROGRAMUL PRINCIPAL - Ruleaza la infinit in fundal
; =============================================================
MAIN:
    ; --- INCARCARE CONSTANTE ---
    LDI R0 0            ; Constanta 0 (utila pentru operatii matematice)
    LDI R1 1            ; Constanta 1
    LDI R2 128          ; Constanta 128 (Marginea LED-urilor, 1000_0000)
    LDI R3 253          ; Adresa LED PORT (0xFC + 1 = 253)
    LDI R4 251          ; Adresa SWITCH PORT (0xFA + 1 = 251)
    LDI R5 248          ; Adresa TIMER HIGH (0xF8 = 248)
    LDI R6 249          ; Adresa TIMER LOW (0xF9 = 249)

    ; --- INITIALIZARE STARE CURENTA ---
    LDI R8 1            ; Aprindem fix primul LED din dreapta
    LDI R7 0            ; Setam directia initiala spre Stanga
    STORE R8 R3         ; Trimitem fizic aprinderea pe placa
    
    LDI R9 255          ; Setam "starea anterioara a switch-urilor" pe o valoare dummy

; --- BUCLA INFINITA DE CITIRE A BUTOANELOR ---
LOOP:
    LOAD R10 R4         ; R10 = Citim starea in timp real a Switch-urilor
    
    ; Verificam daca switch-urile si-au schimbat pozitia fata de ultima citire
    SUB R12 R10 R9      ; R12 = Stare_Curenta - Stare_Veche
    JMPZ LOOP           ; Daca rezultatul e 0 (nu s-a miscat nimic), nu facem nimic!

    ; --- SE EXECUTA DOAR DACA AI MISCAT DE UN SWITCH ---
    ADD R9 R10 R0       ; R9 = R10 (Salvam valoarea curenta ca fiind noua stare veche)

    ; Pregatim valoarea pentru Timer High. Ca sa nu existe o valoare de 0 absolut 
    ; (care ar bloca timerul), facem un OR cu 1 ca macar bitul cel mai mic sa fie activ.
    OR R12 R10 R1       ; R12 = Switch_Val | 1
    
    ; Scriem noile limite in Timer-ul hardware! 
    ; Cu cat valoarea de pe switch-uri e mai mare, cu atat numaratorul va dura mai mult!
    STORE R12 R5        ; TIMER HIGH = Valoarea de pe switch-uri
    STORE R0 R6         ; TIMER LOW  = 0
    
    JMP LOOP            ; Inapoi la paza switch-urilor