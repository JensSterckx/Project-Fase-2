; Dit is een testprogramma voor een SPI op p1.
; Het is de bedoeling om tegen 266kbit/s snelheid de stand van de schakelaars naar buiten te shiften.
; Geschreven door Roggemans M. (MGM) op 05/2012


;Bij dit probeersel heb ik het origineel SPI.asm bestandje gebruikt van op de telescript.
;Dit proberen hervormen om 16 bits naar buiten te sturen maar geen success.


		org	0000h			;startadres programma
		mov	sp,#7fh		;stack klaar zetten
		lcall	initleds		;LED's klaar zetten voor gebruik
		lcall	initdipswitch		;schakelaars klaar voor gebruik
        lcall   initftoetsen  ;De ftoetens klaarzetten voor gebruik
		lcall	initspi		;spi klaar zetten

        mov r3,#FFh

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

        mov r1,#08h
teller:
        ; TELLER op DIGIT 1
        
        mov r0,#01h
        lcall max7219outpacket

        ;mov a,#20
        ;lcall delaya0k05s

        mov p3_data, r1

        djnz r1, teller

ljmp	lus			;blijven doen




; FUNCTIES
; STUUR NAAR MAX7219

; r0 voor het ADRES, r1 voor de DATA
max7219outpacket:
    ;Delays kunnen mss problemen oplossen?
        lcall delay10us
        clr	p1_data.5       ; Chip Select Activeren
        lcall delay10us

        ;???? Hoe pusht hij bits naar buiten?
        ;Beginnen van achter naarbuiten latchen 
        ;10101010
        ;   ->  0
        ;   ->  10
        ;   ->  010
        ;   ->  1010
        ;   ->  ..... of begint hij vanvoor?


        mov	ssc_tbl,r0		;start zenden
spioutbyte1:	
        mov	a,ssc_conh		;testen data weg
        jb	acc.4,spioutbyte1	;wachten tot weg



        mov ssc_tbl,r1		;start zenden
spioutbyte2:
        mov	a,ssc_conh		;testen data weg
        jb	acc.4,spioutbyte2	;wachten tot weg



        lcall delay10us
		setb p1_data.5	    ; Chip Select Deactiveren
        lcall delay10us
ret


; DISPLAY INIT
initMAX7219:
        ; Uit shutdown mode halen
        mov r0,#0Ch          ; ADRES
        mov r1,#01h          ; DATA
        lcall max7219outpacket
        
;ret
        mov a,#20
        lcall delaya0k05s

        ; DisplayTEST
        mov r0,#0Fh          ; ADRES
        mov r1,#01h          ; DATA
        lcall max7219outpacket

        mov a,#20
        lcall delaya0k05s


        ; Normale Operatie starten ;Displaytest uit
        mov r0,#0Fh          ; ADRES
        mov r1,#00h          ; DATA
        lcall max7219outpacket

        ; Alle digits activeren
        mov r0,#0Bh          ; ADRES
        mov r1,#07h          ; DATA
        lcall max7219outpacket

        ; FONT Decode voor alle digits enablen (BCD)
        mov r0,#09h          ; ADRES
        mov r1,#FFh          ; DATA
        lcall max7219outpacket

        ; Halve helderheid
        mov r0,#0Ah          ; ADRES
        mov r1,#08h          ; DATA
        lcall max7219outpacket

        ; DIGIT 1 op 1 BCD zetten
        mov r0,#01h          ; ADRES
        mov r1,#01h          ; DATA
        lcall max7219outpacket
ret

; SPI
initspi:	
        mov	p1_dir,#00101100b	;juiste pinnen als output schakelen (1)   
        ;van Poort 1 -> Pin 2,3 en 5 als output?
        ; POORT 1=     http://html.alldatasheet.com/html-pdf/153361/INFINEON/SAF-XC888-8FFI/5949/15/SAF-XC888-8FFI.html  
        ;   PIN 2: CLK?         -> PIN 5 VAN SPI HEADER
        ;   PIN 3: MOSI? output -> PIN 4 VAN SPI 
        ;  
        ;   PIN 5: Chip Select  -> PIN 2 VAN SPI

		mov	port_page,#02h	;altsel registers beschikbaar maken
		mov	p1_altsel0,#00011100b	;alt functies SPI
		mov	p1_altsel1,#00000000b	;alt functies SPIa
		mov	port_page,#00h	;terug naar basis laten wijzen

        ;TEST
        ;mov ssc_pisel, p1_data ?? of vindt die dat automatich?

		mov	ssc_brh,#00h		;baud rate waarde inladen
		mov	ssc_brl,#2ch		;idem
		mov	ssc_conl,#07h		;8 bit data, rest is niet belangrijk in mijn voorbeeld
		;mov	ssc_conh,#01000000b	;stop mode (uitgeschakelde SPI)
		mov	ssc_conh,#11000000b	;active mode (inschakelen SPI)

        setb p1_data.5 ;Chip Select op hoog zetten (Uit)
ret


		
;ret

#include	"c:\xcez1.inc"
