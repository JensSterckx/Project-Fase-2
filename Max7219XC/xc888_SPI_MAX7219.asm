;START PROGRAMMA
org	0000h			;start adres hoofd programma
ljmp initmain

org 000Bh       ;Interruptvector van TimerO
ljmp interrupt  ;Label voor de interrupt code


initmain:
		mov	sp,#7Fh		    ;stackpointer klaar zetten

	    lcall initlcd		;lcd klaar zetten
        lcall setlcd
		;lcall lcdlighton	;achtergrondverlichting inschakelen
        lcall initftoetsen
        lcall initleds

        lcall initadc
        lcall initsio       ;serieele input en output 9600 baud

		mov	a,#03h			;cursor uitschakelen
		lcall	lcdoutchar

		lcall initmax		;de max klaar zetten (met incl POORT 5)
        lcall clearmax      ;Alle digits leeg maken
        lcall disableMAXdecode;De MAX zal alle input voor elk segment ruw inpakken (Data bepaalt welk segmentje er oplicht)
        ;lcall fillmax

        lcall initinterrupt

        lcall printmax

main:	
	
        mov	a,#0dh			;cursor positionneren
		lcall lcdoutchar        
        mov a,DISP_STATUS
        lcall lcdoutbyte

        ;DATA INLEZEN VAN SIO EN OP DE DIGITS REPRESENTEREN
        ;We gebruiken de MSB van het ADRES (Dat niet gebruikt wordt door de MAX voor onze eigen opcodes)


        lcall sioinchar ;Eerst het adres inlezen
        push acc        ;Tijdelijk storen

        lcall sioinchar ;Data inladen
        mov b,a         ;Storen in b
        pop acc         ;Adres restoren
        lcall outmax

        ;OUTPUT DEBUG
        push acc
        mov	a,#c3h
		lcall lcdoutchar
        pop acc
        lcall lcdoutbyte

        push acc
        mov	a,#97h
		lcall lcdoutchar
        mov a,b
        lcall lcdoutbyte
        pop acc
        
ljmp main

printmax:
        mov a,#04h
        mov b,#01111101b
        lcall outmax
        
        mov a,#13h
        mov b,#01001111b
        lcall outmax

        mov a,#02h
        mov b,#00010101b
        lcall outmax

        mov a,#11h
        mov b,#11011011b
        lcall outmax
ret


; printlcd drukt de teller af op het lcd scherm
setlcd:
    ;ADRESSEN
    ; 80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f 90 91 92 93
    ; c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf d0 d1 d2 d3
    ; 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f a0 a1 a2 a3 a4 a5 a6 a7
    ; d4 d5 d6 d7 d8 d9 da db dc dd de df e0 e1 e2 e3 e4 e5 e6 e7
    
        mov	a,#c0h
		lcall lcdoutchar
        mov a,#'A'
        lcall lcdoutchar
        mov a,#':'
        lcall lcdoutchar
        mov a,#' '
        lcall lcdoutchar
        mov a,#'N'
        lcall lcdoutchar

        mov	a,#94h
		lcall lcdoutchar  
        mov a,#'D'
        lcall lcdoutchar
        mov a,#':'
        lcall lcdoutchar    
        mov a,#' '
        lcall lcdoutchar
        mov a,#'N'
        lcall lcdoutchar
ret

;Interrupt klaarzetten voor acties uit te voeren zonder te hoeven wachten op een SIO input.
initinterrupt:
    mov th0,#00h
    mov tl0,#00h
    mov tmod,#00000001b ;16 bit timer

    setb tr0            ;De timer begint nu met tellen.
    setb et0            ;Nu laten we de timer toe om interrupts te genereren (Nu pas, we willen geen interrupts tijdens het initen van onze waardes)
    setb EA             ;Het algemeen toe laten om interrupts naar de core te sturen.
ret

;DEZE INTERRUPT CHECK OF P2.0 INGEDRUKT IS, ZOLANG DEZE INGEDRUKT IS, GAAT DISPLAY OP TEST
;OOK VOOR HELDERHEID
interrupt:
    jb DISP_STATUS.7, return_ifa ;We skippen deze interrupt als we iets aant sturen zijn.

    push acc            ;Plaatsen onze status van de Accu in de stackpointer
    push PSW            ;Plaatsen onze program status in de stackpointer

    lcall maxpotmeter   ;Potentiometer helderheid

checkknop_loop:    
    mov a, p2_data
    jnb acc.3, checkknop_loop  ;Loop om de display stil te kunnen laten staan

    jb acc.0, return_i    ;Als test niet ingedrukt is, mogen we uit interrupt anders test aant tot wel loslaten
    lcall enableMAXdisplaytest
checkknop_test:   
    mov a, p2_data
    jnb acc.0, checkknop_test

disptestuit_i:
    lcall disableMAXdisplaytest
return_i:
    pop PSW             ;Halen de programstatus weer van de stack
    pop acc             ;Halen waarde van de acc weer van de stack
return_ifa:
reti



#include    "ADC.inc"       ;Herberekening van ADC naar correcte 16 bits (rechts uitgelijnd)
#include    "MAX7219.inc"   ;Functies voor het besturen van de MAX7219 driver
#include	"c:\xcez1.inc"

