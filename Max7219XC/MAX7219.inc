
;GEHEUGEN PLAATSEN RESERVEREN
DISP_STATUS		equ	20h     ;.x =   true(1) / false(0)
                            ;.0 = Display Test / Normal OP
                            ;.1 = Decode ON / OFF    

                            ;.7 = Transmission lock ON / OFF (Deze bit wordt gezet als er iets verzonden wordt door de main (interrupts moeten hier dus overgeslaan worden)
DISP_CHIPS      equ 21h     ;Aantal MAX chips in daisy chain

DISP_STORE1     equ 22h
DISP_STORE2     equ 23h


; Dit programma test de MAX7219 (met een 7-segment uitlezing).
; Het programma zal eerst de module initialiseren. Daarna komt er een teller op die
; op de 8 cijfers een getal laat zien dat 1 verschilt.
; We drukken de teller ook op de LCD af (ter controle)
; Geschreven door Roggemans M. (MGM) op 12/2015 V1.0
; Uitgebreid door Sterckx Jens op 07/12/15 (Aanpassingen & Helderheid door POT meter functie)
;
; Aansluitingen:
; P5_data.0=clk (bruine draad)
; P5_data.1=cs  (gele draad)
; P5_data.2=din (witte draad)
;
; Nodige geheugenplaatsen:  DISP_STATUS (BIT ADRESSABLE!)
;                           DISP_CHIP

; initmax zet de max klaar voor gebruik. Dit doen we door 16 bit patronen op te sturen
initmax:	
        lcall initp5        ;Poort 5 klaarzetten

        mov	a,#0Ch			;mode display
		mov	b,#01h			;normal mode
		lcall outmax		;verzenden

		mov	a,#0Ah			;intensity
		mov	b,#00h			;laagste intensiteit
		lcall outmax

		mov	a,#0Bh			;scan limit
		mov	b,#07h			;scan all
		lcall	outmax

        mov DISP_STATUS,#00h
        mov DISP_CHIPS,#02h
	ret

; initp5 zet de lijnen van p5 als output. p5 is NIET bit adresseerbaar!!!!!!
; De poort staat per definitie als input. Daar maken we output van. De poort staat dan 
; per definitie in de PUSH-PULL mode. Verdere inits zijn niet nodig.
initp5:	
        mov	p5_dir,#FFh		;alle pinnen als output
		mov	p5_data,#FFh	;alle uitgangen op 1
	ret


; enableMAXdecode/disableMAXdecode zal de Code B Font encoding van de max7219 enablen/disablen
;
; input:
; niets
; 
;
; output:
; Sturen naar MAX voor het enablen/disablene van het FONT
;
; gebruikt:
; niets
enableMAXdecode:
        push acc
        push b

		mov	a,#09h			;decode mode
		mov	b,#FFh			;decode all digits
		lcall outmax
        
        setb DISP_STATUS.1

        pop b
        pop acc
ret
disableMAXdecode:
        push acc
        push b

		mov	a,#09h			;decode mode
		mov	b,#00h			;decode all digits
		lcall outmax

        clr DISP_STATUS.1

        pop b
        pop acc
ret


; enableMAXdisplaytest/disableMAXdisplaytest zal de max7219 in displaytest zetten/uithalen
;
; input:
; niets
; 
;
; output:
; Sturen naar MAX voor het enablen/disablene van de displaytest
;
; gebruikt:
; niets
enableMAXdisplaytest:
        push acc
        push b

    	mov	a,#0Fh			;Displaytest mode
		mov	b,#01h			;aan
		lcall outmax

        setb DISP_STATUS.0
    
        pop b
        pop acc
ret
disableMAXdisplaytest:
        push acc
        push b

    	mov	a,#0Fh			;Displaytest mode
		mov	b,#00h			;uit
		lcall outmax

        ;voor zekerheid toch weer in normal mode zetten
        mov	a,#0Ch			;mode display
		mov	b,#01h			;normal mode
		lcall outmax		;verzenden
    
        clr DISP_STATUS.0

        pop b
        pop acc
ret


; maxpotmeter zal de helderheid van de potmeter uitlezen en als helderheid instellen
;
; input:
; niets
; 
;
; output:
; Potmeter naar helderheid MAX
;
; gebruikt:
; r0, r1, r2, r3
maxpotmeter:
        push acc
        push b

        lcall getADC        ;(ADC.inc)

        mov r1,a
        mov r0,b
        mov r3,#00h
        mov r2,#64          ;1024 / 64 == 0 - F (Goed voor brightness van MAX)
        lcall div16

		mov	a,#FAh			;Intensity
		mov	b,r2			;Potmeter intensiteit
		lcall outmax

        pop b
        pop acc
ret

; clearmax zal elke digit blank maken
; ATTENTIE: DIT ZAL DE enableMAXdecode uitvoeren (Decode zal op einde van deze routine aan staan)
;   Reden hiervoor is blank met encoding is FFh zonder is 00h...
;   Dus als decode toch uit moet, lcall disableMAXdecode
;
; input:
; niets
; 
; output:
; niets
;
; gebruikt:
; niets
clearmax:
    push acc
    push b

    lcall enableMAXdecode

   	mov	a,#01h
    mov b,#00h
	lcall outmax

    mov	a,#02h
	lcall outmax

    mov	a,#03h
	lcall outmax

    mov	a,#04h
	lcall outmax

    mov	a,#05h
	lcall outmax

    mov	a,#06h
	lcall outmax

    mov	a,#07h
	lcall outmax

    mov	a,#08h
	lcall outmax

    pop b
    pop acc
ret

; fillmax zal elke digit laten oplichten (NIET IN TEST MODE) 
; ATTENTIE: DIT ZAL DE disableMAXdecode uitvoeren (Decode zal op einde van deze routine uit staan)
;
; input:
; niets
; 
; output:
; niets
;
; gebruikt:
; niets
fillmax:
    push acc
    push b

    lcall disableMAXdecode

   	mov	a,#01h
    mov b,#FFh
	lcall outmax

    mov	a,#02h
	lcall outmax

    mov	a,#03h
	lcall outmax

    mov	a,#04h
	lcall outmax

    mov	a,#05h
	lcall outmax

    mov	a,#06h
	lcall outmax

    mov	a,#07h
	lcall outmax

    mov	a,#08h
	lcall outmax

    pop b
    pop acc
ret


; outmax stuurt 16 bit naar de max. 
;
; input:
; a register = adres(LSB) + indicatie voor daisy chain(MSB F = elke chip). 
;                       (de MSB worden niet gebruikt door de MAX, we gaan deze gebruiken voor de index aan te geven welke chip we nodig hebben (Vult derest op met 00 00 NoOp) 0 = Dichste MAX f is laatste chip in rij.
; b register = data
;
; Eerst worden de 8 bits van a naar buiten gestuurd (msb eerst), daarna die van b (msb eerst)
; ook cs en clk worden aangepast. Omdat P5 niet bit adresseerbaar is gebruiken we ANL en ORL
; om de bits te manipuleren.
;
; output:
; data naar MAX
;
; gebruikt:
; niets
outmax:
        jb DISP_STATUS.7, outmax_dret ;Zorgt ervoor dat er niets (bvb met interrupt) 2 keer kan gezonden / verzending onderbroken worden.
        setb DISP_STATUS.7       ;outmax locken





        ;Chip uit Adres halen
        swap a                   ;MSB->LSB
        mov DISP_STORE1,a
        anl DISP_STORE1,#0Fh       ;Enkel de LSB behouden
        swap a                   ;TERUG GOED ZETTEN
    

        lcall outmax_start       ;Werkelijke data versturen

        mov p3_data, DISP_STORE1


        ;Eerst de achterliggende dummy chips NoOppen

        push acc
        mov a,DISP_CHIPS
        ljmp outmax_dummyb41
outmax_dummyb4:
        push acc
        mov a,#00h               ;Adres 00h = NoOp
        mov b,#00h
        lcall outmax_start
        pop acc
        dec a
outmax_dummyb41:
        cjne a, DISP_STORE1, outmax_dummyb4

        ;Werkelijke data doorsturen
        pop acc
        lcall outmax_start

;dan de voorgaande dummy chips NoOppen
        ljmp outmax_dummyafter1
        mov DISP_STORE2,a
outmax_dummyafter:
        ;push acc
        mov a,#00h               ;Adres 00h = NoOp
        mov b,#00h
        lcall outmax_start
        ;pop acc
outmax_dummyafter1:
        djnz DISP_STORE2, outmax_dummyafter



        clr DISP_STATUS.7 ;Lock vrijmaken
outmax_dret:
    ret







outmax_start: ;De start voor het zenden van adres en data voor 1 chip
        push acc			     ;registers bewaren op stack
		push b
		anl	p5_data,#11111100b	 ;cs en clk laag maken
		mov	b,#8			     ;bitteller
outmax_lus1:		
        rlc	a			         ;msb in carry

		jc outmax_een			 ;als carry 1, bit din op een
		anl	p5_data,#11111000b	 ;anders op 0
	ljmp outmax_verder
outmax_een:		
        orl	p5_data,#11111100b	 ;din=1, cs en clk niet aanpassen
		nop				         ;mini vertraging
outmax_verder:	
        orl	p5_data,#11111001b	 ;clk op 1
		nop				         ;mini vertraging
		anl	p5_data,#11111100b	 ;klok terug laag, cs blijft laag
	djnz b,outmax_lus1

		pop	acc			         ;b herstellen in accu
		push acc			     ;terug bewaren
		mov	b,#8			     ;bitteller
outmax_lus2:		
        rlc	a			         ;msb in carry

		jc outmax_een1			 ;als carry 1, bit din op een
		anl	p5_data,#11111000b	 ;anders op 0
	ljmp outmax_verder1
outmax_een1:		
        orl	p5_data,#11111100b	 ;din=1, cs en clk niet aanpassen
outmax_verder1:	
        orl	p5_data,#11111001b	 ;clk op 1
		nop				         ;mini vertraging
		anl	p5_data,#11111100b	 ;klok terug laag, cs blijft laag
	djnz b,outmax_lus2

	    orl	p5_data,#11111110b	 ;eerst cs hoog, klok mag laag blijven (moet volgens datasheet)
		pop	b			         ;regs herstellen
		pop	acc			         ;klaar

        ;clr DISP_STATUS.7 ;Lock vrijmaken
outmax_ret:
    ret