; Dit programma test de MAX7219 (met een 7-segment uitlezing).
; Het programma zal eerst de module initialiseren. Daarna komt er een teller op die
; op de 8 cijfers een getal laat zien dat 1 verschilt.
; We drukken de teller ook op de LCD af (ter controle)
; Geschreven door Roggemans M. (MGM) op 12/2015 V1.0
;
; Aansluitingen:
; P5_data.0=clk
; P5_data.1=cs
; P5_data.2=din

teller		equ	20h			;register waarin de teller zit

		org	0000h			;start adres programma
		mov	sp,#7fh		;stackpointer klaar zetten
		lcall	inits			;alles initialiseren
lus:		
        lcall	printmax		;teller printen op max
		lcall	printlcd
		inc 	teller			;teller met 1 vermeerderen
		anl	teller,#0fh		;begrenzen op 4 bit (00-01-02-...0f-00-01-....)
		mov	a,#10			;delay toevoegen
		lcall	delaya0k05s		;tijdsvertraging oproepen
		ljmp	lus

; printmax drukt de teller af op de max (telekens eentje bij)

printmax:

ret

printmaxori:	
        mov	b,teller		;teller in b laden
		mov	a,#01			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		setb	b.7			;decimale punt op 1
		mov	a,#02			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		clr	b.7			;decimale punt uit
		mov	a,#03			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		setb	b.7			;decimale punt op 1
		mov	a,#04			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		clr	b.7			;decimale punt uit
		mov	a,#05			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		setb	b.7			;decimale punt op 1
		mov	a,#06			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		clr	b.7			;decimale punt uit
		mov	a,#07			;adres karakter
		lcall	outmax
		inc	b			;eentje bij tellen
		anl	b,#0fh			;beperken (niet nodig volgens datasheet)
		setb	b.7			;decimale punt op 1
		mov	a,#08			;adres karakter
		lcall	outmax
ret

; printlcd drukt de teller af op het lcd scherm

printlcd:	mov	a,#0dh			;cursor positionneren
		lcall	lcdoutchar
		mov	a,teller		;teller afdrukken
		lcall	lcdoutbyte
		ret

; inits zet alle I/O klaar voor gebruik

inits:		lcall	initlcd		;lcd klaar zetten
		lcall	lcdlighton		;achtergrondverlichting inschakelen
		mov	a,#03h			;cursor uitschakelen
		lcall	lcdoutchar
		mov	teller,#00h		;teller van 0 laten starten
		lcall	initp5			;poort 5 klaar zetten\
		lcall	initmax		;de max klaar zetten
		ret

; initp5 zet de lijnen van p5 als output. p5 is NIET bit adresseerbaar!!!!!!
; De poort staat per definitie als input. Daar maken we output van. De poort staat dan 
; per definitie in de PUSH-PULL mode. Verdere inits zijn niet nodig.

initp5:	
        mov	p5_dir,#ffh		;alle pinnen als output
		mov	p5_data,#ffh		;alle uitgangen op 1
		ret
		
; initmax zet de max klaar voor gebruik. Dit doen we door 16 bit patronen op te sturen

initmax:	
        mov	a,#0Ch			;mode display
		mov	b,#01h			;normal mode
		lcall	outmax			;verzenden
		mov	a,#09h			;decode mode
		mov	b,#FFh			;decode all digits
		lcall	outmax
		mov	a,#0Ah			;intensity
		mov	b,#05h			;halve intensiteit
		lcall	outmax
		mov	a,#0Bh			;scan limit
		mov	b,#07h			;scan all
		lcall	outmax
	ret


; outmax stuurt 16 bit naar de max. 
; input:
; a register = adres
; b register = data
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
        push	acc			;registers bewaren op stack
		push	b
		anl	p5_data,#11111100b	;cs en clk laag maken
		mov	b,#8			;bitteller
lus1:		
        rlc	a			;msb in carry
		jc	een			;als carry 1, bit din op een
		anl	p5_data,#11111000b	;anders op 0
	ljmp	verder
een:		
        orl	p5_data,#11111100b	;din=1, cs en clk niet aanpassen
		nop				;mini vertraging
verder:	
        orl	p5_data,#11111001b	;clk op 1
		nop				;mini vertraging
		anl	p5_data,#11111100b	;klok terug laag, cs blijft laag
		djnz	b,lus1
		pop	acc			;b herstellen in accu
		push	acc			;terug bewaren
		mov	b,#8			;bitteller
lus2:		
        rlc	a			;msb in carry
		jc	een1			;als carry 1, bit din op een
		anl	p5_data,#11111000b	;anders op 0
	ljmp	verder1
een1:		
        orl	p5_data,#11111100b	;din=1, cs en clk niet aanpassen
verder1:	
        orl	p5_data,#11111001b	;clk op 1
		nop				;mini vertraging
		anl	p5_data,#11111100b	;klok terug laag, cs blijft laag
	djnz	b,lus2
		orl	p5_data,#11111110b	;eerst cs hoog, klok mag laag blijven (moet volgens datasheet)
		pop	b			;regs herstellen
		pop	acc			;klaar
    ret

#include	"c:\xcez1.inc"
