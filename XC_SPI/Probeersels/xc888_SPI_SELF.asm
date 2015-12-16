;Bij deze poging heb ik geprobeerd om de data zelf naar buiten te sturen.
;DE MAX7219 is niet 100 een spi device, maar verwacht gewoon dat de bit klaar staat als de CLK hoog gaat.
;Bij dit probeersel heb ik dus zelf de pinnen hoog en laag proberen zetten om zo data naar buiten te shiften.

;Zonder success.


		org	0000h			;startadres programma
		mov	sp,#7fh		;stack klaar zetten
		lcall	initleds		;LED's klaar zetten voor gebruik
		lcall	initdipswitch		;schakelaars klaar voor gebruik
        lcall   initftoetsen  ;De ftoetens klaarzetten voor gebruik
		lcall	initspi		;spi klaar zetten

        lcall   initmax7219


lus:
        ; DIGIT 1 op 1 BCD zetten
        ;mov r0,#01h          ; ADRES
        ;mov r1,#01h          ; DATA
        ;lcall max7219outpacket
ljmp lus

initmax7219:

        mov a,#40
        lcall delaya0k05s

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

                mov a,#20
        lcall delaya0k05s

        ; Alle digits activeren
        mov r0,#0Bh          ; ADRES
        mov r1,#07h          ; DATA
        lcall max7219outpacket

                mov a,#20
        lcall delaya0k05s

        ; FONT Decode voor alle digits enablen (BCD)
        mov r0,#09h          ; ADRES
        mov r1,#FFh          ; DATA
        lcall max7219outpacket

        mov a,#20
        lcall delaya0k05s

        ; Halve helderheid
        mov r0,#0Ah          ; ADRES
        mov r1,#08h          ; DATA
        lcall max7219outpacket

                mov a,#20
        lcall delaya0k05s

        ; DIGIT 1 op 1 BCD zetten
        mov r0,#01h          ; ADRES
         mov r1,#01h          ; DATA
        lcall max7219outpacket
ret

;OUTPUT NAAR POORT 1 VOOR DISPLAY DRIVER
max7219outpacket:
        clr p1_data.5  ;CS DOWN
        lcall delay1ms

        mov b,#08h
        ;Data in accu steken
        mov a,r1
        mov r6,#02h

senddata:
        mov p3_data,b

        ;VERLOOP
        ;CS op LOW
        ;DATA BIT KLAAR ZETTEN
            ;EFFE DELAY?
        ;CLOCK RISE
            ;EFFE DELAY?
        ;CLOCK DOWN
            ;EFFE DELAY?
        ;DATABIT KLAAR ZETTEN
            ;EFFE DELAY
        ;CLOCK RISE
            ;EFFE DELAY
        ;CLOCK DOWN


;DATA NAAR BUITEN STUREN

;Dacht de Bits in een andere richting te sturen... (Nu komt er niets op de display)
        jb acc.7, setd1
setd0:
        setb P1_data.3
        ljmp donesetd
setd1:
        clr P1_data.3
donesetd:
        rl a

        ;Eerste manier (Trekt het meeste op die van PI), 
;        jb acc.0, setd1
;setd0:
;        setb P1_data.3
;        ljmp donesetd
;setd1:
;        clr P1_data.3
;donesetd:
;        rr a

        lcall delay1ms

        setb P1_data.2

        ;mov r5,a
        ;mov a,#05
        ;lcall delaya0k05s
        ;mov a,r5
        lcall delay1ms
        lcall delay1ms

        clr P1_data.2

        ;mov r5,a
        ;mov a,#05
        ;lcall delaya0k05s
        ;mov a,r5
        lcall delay1ms

    djnz b, senddata
    ;Bitteller reset
        mov b,#08h
    ;Adres in accu steken
        mov a,r0

    djnz r6, senddata ;Start sending adress out

        lcall delay1ms
        setb p1_data.5
        lcall delay1ms    
ret


initspi:	
        mov	p1_dir,#00101100b	;juiste pinnen als output schakelen (1)   
        ;van Poort 1 -> Pin 2,3 en 5 als output?
        ; POORT 1=     http://html.alldatasheet.com/html-pdf/153361/INFINEON/SAF-XC888-8FFI/5949/15/SAF-XC888-8FFI.html  
        ;   PIN 2: CLK?         -> PIN 5 VAN SPI HEADER
        ;   PIN 3: MOSI? output -> PIN 4 VAN SPI 
        ;  
        ;   PIN 5: Chip Select  -> PIN 2 VAN SPI


        setb p1_data.5
        clr p1_data.3
        clr p1_data.2

        lcall delay1ms

        lcall delay1ms

        lcall delay1ms
ret

#include	"c:\xcez1.inc"
