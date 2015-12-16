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
getADC:
    lcall adcpotmeter ;HERNOEM NAAR DE ADC INGANG DA GE WILT
	;lcall adclm335
    
    ;mov ADC_H, a
    ;mov ADC_L, b

    push acc

    mov a,b
    anl a,#11000000b

    rl a
    rl a
	
    mov b,a
    ;mov ADC_L,b
    ;mov a,ADC_H
    
    pop acc
    push acc

    rl a
    rl a

    anl a,#11111100b

    orl a,b
    mov b,a

    pop acc
    anl a,#11000000b

    rl a
    rl a
    
    ;mov ADC_H,a
	;mov ADC_L,b



ret