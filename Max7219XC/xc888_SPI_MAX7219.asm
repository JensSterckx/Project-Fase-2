
;GEHEUGEN PLAATSEN RESERVEREN
DISP_STATUS		equ	20h     ;.0 = Display Test / Normal OP    



;START PROGRAMMA
org	0000h			;start adres hoofd programma
ljmp initmain

org 000Bh       ;Interruptvector van TimerO
ljmp interrupt  ;Label voor de interrupt code


initmain:
		mov	sp,#7fh		    ;stackpointer klaar zetten

	    lcall	initlcd		;lcd klaar zetten
		lcall	lcdlighton	;achtergrondverlichting inschakelen

        lcall initadc
        lcall initsio       ;serieele input en output 9600 baud

		mov	a,#03h			;cursor uitschakelen
		lcall	lcdoutchar

		lcall initmax		;de max klaar zetten (met incl POORT 5)
        lcall clearmax      ;Alle digits leeg maken
        lcall disableMAXdecode;De MAX zal alle input voor elk segment ruw inpakken (Data bepaalt welk segmentje er oplicht)

main:		

        lcall maxpotmeter

        ;DATA INLEZEN VAN SIO EN OP DE DIGITS REPRESENTEREN
        ;We gebruiken de MSB van het ADRES (Dat niet gebruikt wordt door de MAX voor onze eigen opcodes)


        lcall sioinchar ;Eerst het adres inlezen
        push acc        ;Tijdelijk storen
        lcall sioinchar ;Data inladen
        mov b,a         ;Storen in b
        pop acc         ;Adres restoren

        lcall outmax

ljmp main

; printmax drukt de teller af op de max (telekens eentje bij)

printmax:
        mov a,#08
        mov b,#01111101b
        lcall outmax
        
        mov a,#07
        mov b,#01001111b
        lcall outmax

        mov a,#06
        mov b,#00010101b
        lcall outmax

        mov a,#05
        mov b,#11011011b
        lcall outmax
ret


; printlcd drukt de teller af op het lcd scherm

printlcd:	
        ;mov	a,#0dh			;cursor positionneren
		;lcall lcdoutchar        
		;mov	a,teller		;teller afdrukken
		;lcall lcdoutbyte               
ret


;DEZE INTERRUPT CHECK OF P2.0 INGEDRUKT IS, ZOLANG DEZE INGEDRUKT IS, GAAT DISPLAY OP TEST
interrupt:
    push acc            ;Plaatsen onze status van de Accu in de stackpointer
    push PSW            ;Plaatsen onze program status in de stackpointer

    mov a, p2_data
    ;

disptestuit_i:
    
return_i:
    pop PSW             ;Halen de programstatus weer van de stack
    pop acc             ;Halen waarde van de acc weer van de stack
reti



#include    "ADC.inc"       ;Herberekening van ADC naar correcte 16 bits (rechts uitgelijnd)
#include    "MAX7219.inc"   ;Functies voor het besturen van de MAX7219 driver
#include	"c:\xcez1.inc"
