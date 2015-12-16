; Dit is een testprogramma voor een SPI op p1.
; Het is de bedoeling om tegen 266kbit/s snelheid de stand van de schakelaars naar buiten te shiften.
; Geschreven door Roggemans M. (MGM) op 05/2012
; Aangepast door Jens Sterckx (NSS) op 12/2015 voor MAX7219 

		org	0000h			;startadres programma
		mov	sp,#7fh		;stack klaar zetten
		lcall	initleds		;LED's klaar zetten voor gebruik
		lcall	initdipswitch		;schakelaars klaar voor gebruik
        lcall   initftoetsen  ;De ftoetens klaarzetten voor gebruik
		lcall	initspi		;spi klaar zetten

        mov a,#20
        lcall delaya0k05s

        lcall   initMAX7219

lus:		
;        mov p3_data,#01h

        ;EENEN

;       mov r0,#ffh

;eenen:
;       mov a,#01
;        lcall delaya0k05s

;       mov p3_data,r0
;       clr	p1_data.5       ; Chip Select Activeren
;		mov	a,#FFh		    ; ADRES VOOR DISPLAY TEST
;		lcall spioutbyte	; Buiten sturen
;
;       mov	a,#FFh		    ; DATA: 01 is aan 00 is uit
;		lcall spioutbyte	; Buiten sturen
;		setb p1_data.5	    ; Chip Select deactiveren
;
;djnz r0,eenen



;pauseget1: 
;        mov a,p2_data 
;        jb ACC.0,pauseget1 
;pauseget2: ;Wachten tot we knop weer loslaten
;        mov a,p2_data 
 ;       jnb ACC.0,pauseget2


   
		;NULLEN
;       mov r0,#ffh
;nullen:
;       mov p3_data,r0
;
;       clr	p1_data.5       ; Chip Select Activeren
;		mov	a,#00h		    ; ADRES VOOR DISPLAY TEST
;		lcall spioutbyte	; Buiten sturen
;
;       mov	a,#00h		    ; DATA: 01 is aan 00 is uit
;		lcall spioutbyte	; Buiten sturen
;		setb p1_data.5	    ; Chip Select deactiveren
;
;djnz r0,nullen



;pauseget3: 
;        mov a,p2_data 
;        jb ACC.0,pauseget3 
;pauseget4: ;Wachten tot we knop weer loslaten
;        mov a,p2_data 
;        jnb ACC.0,pauseget4

        mov r0,#09h
teller:
        ; TELLER op DIGIT 1
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#01h		    ; ADRES
		lcall spioutbyte	; Send

        mov	a,r0		    ; DATA
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS

        mov a,#20
        lcall delaya0k05s

        djnz r0, teller

ljmp	lus			;blijven doen




; FUNCTIES
; STUUR NAAR MAX7219
max7219outbyte:


ret


; DISPLAY INIT
initMAX7219:
        ; DisplayTEST
        lcall delay10us
        clr	p1_data.5       ; Chip Select Activeren
        lcall delay10us

		mov	a,#0Fh		    ; ADRES VOOR DISPLAY TEST
		lcall spioutbyte	; Buiten sturen

        mov	a,#01h		    ; DATA: 01 is aan 00 is uit
		lcall spioutbyte	; Buiten sturen

        lcall delay10us
		setb p1_data.5	    ; Chip Select deactiveren
        lcall delay10us

        mov a,#20
        lcall delaya0k05s

        ; Normale Operatie starten ;Displaytest uit
        lcall delay10us
        clr	p1_data.5       ; CS
        lcall delay10us

		mov	a,#0Fh		    ; ADRES VOOR DISPLAY TEST
		lcall spioutbyte	; Send

        mov	a,#00h		    ; DATA: 01 is aan 00 is uit
		lcall spioutbyte	; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms

        ; Uit shutdown mode halen
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#0Ch		    ; ADRES VOOR NORMAL MODE
		lcall spioutbyte	; Send

        mov	a,#01h		    ; Data 1 = aan, 0 = shutdown
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms

        ; Alle digits activeren
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#0Bh		    ; ADRES
		lcall spioutbyte	; Send

        mov	a,#07h		    ; DATA
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms

        ; FONT Decode voor alle digits enablen (BCD)
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#09h		    ; ADRES
		lcall spioutbyte	; Send

        mov	a,#FFh		    ; DATA
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms

        ; Halve helderheid
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#0Ah		    ; ADRES
		lcall spioutbyte	; Send

        mov	a,#08h		    ; DATA
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms

        ; DIGIT 1 op 1 BCD zetten
        lcall delay10us
        clr	p1_data.5		; CS
        lcall delay10us

		mov	a,#01h		    ; ADRES
		lcall spioutbyte	; Send

        mov	a,#01h		    ; DATA
		lcall spioutbyte    ; Send

        lcall delay10us
		setb p1_data.5		; CS
        lcall delay10us

        ;lcall delay1ms
ret

; SPI
initspi:	
        mov	p1_dir,#00101100b	;juiste pinnen als output schakelen (1)   
        ;van Poort 1 -> Pin 2,3 en 5 als output?
        ; POORT 1=     http://www.datasheetspdf.com/mobile/552549/XC888.pdf?p=2  
        ;   PIN 2: CLK?  MOSI?  -> PIN 5 VAN SPI  
        ;   PIN 3: MOSI? CLK?   -> PIN 4 VAN SPI    ::  SSC CLOCK OUTPUT VOLGENDS URL
        ;   PIN 4: -> PIN 3 VAN SPI :: SSC Master Transmit Output  (Volgends bovende URL)
        ;   PIN 5: Chip Select  -> PIN 2 VAN SPI

		mov	port_page,#02h	;altsel registers beschikbaar maken
		mov	p1_altsel0,#00011100b	;alt functies SPI
		mov	p1_altsel1,#00000000b	;alt functies SPIa
		mov	port_page,#00h	;terug naar basis laten wijzen
		mov	ssc_brh,#00h		;baud rate waarde inladen
		mov	ssc_brl,#2ch		;idem
		mov	ssc_conl,#07h		;8 bit data, rest is niet belangrijk in mijn voorbeeld
		;mov	ssc_conh,#01000000b	;stop mode (uitgeschakelde SPI)
		mov	ssc_conh,#11000000b	;active mode (inschakelen SPI)

        setb p1_data.5 ;Chip Select op hoog zetten (Uit)
ret

spioutbyte:	
        mov	ssc_tbl,a		;start zenden
spioutbyte1:	
        mov	a,ssc_conh		;testen data weg
		jb	acc.4,spioutbyte1	;wachten tot weg
ret

#include	"c:\xcez1.inc"
