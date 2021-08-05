; Archivo: Lab_01.s
; Dispositivo: PIC16F887
; Autor: Nicolas Urioste
; Compilador: pic.as (v2.31) MPLAB v5.50
;
; Programa: contador en puerto A y puerto B con suma en el puerto D
; Hardware: LEDS en puerto A, botones pushdown en RC0 y RC1
;	    LEDS en puerto B, botones pushdown en RC2 y RC3
;	    LEDS en puerto C
;    
; Creado 03/08/2021
; Modificado: 03/08/2021   
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

  
  
;----------------- Variables -------------------------
PSECT updata_bank0
    cont_small:	DS  2

    
PSECT	resVect, class=CODE, abs, delta=2
    
;------------------ Vector Reset-------------------------
ORG 00h
restVec:
    PAGESEL main
    goto    main
    
PSECT code, delta=2, abs
 ORG 100h   ;posicion donde empieza el codigo
 
main:
    call base
    ;call reloj
    
;----------------- loop principal--------------------
loop:
    btfsc   RC0	    ;revisa si el boton fue precionado, en el caso que 
		    ;si se ejecuta la siguiente instrucion
    call    inc_A   
    btfsc   RC1	    ;lo mismo que RC0
    call    dec_A   //primer ciclo
    
    btfsc   RC2
    call    inc_B
    btfsc   RC3
    call    dec_B   //segundo ciclo
    
    btfsc   RC4
    call    ver_suma
    goto    loop	;loop bezconechnasty
    

base:
        //Configurar al PIC
    bsf	    STATUS, 5   ;bit 5 como 1
    bsf	    STATUS, 6   ;bit 6 como 1, banco 3
    clrf    ANSEL
    clrf    ANSELH
    
    bsf	    STATUS, 5   ;bit 5 como 1
    bcf	    STATUS, 6   ;bit 6 como 0, banco 1
    clrf    TRISA   ;port A como salida
    clrf    TRISB   ;port B como salida
    clrf    TRISD
    
    bcf	    STATUS, 5   ;bit 5 como 0
    bcf	    STATUS, 6   ;bit 6 como 0, banco 0
    clrf    PORTA
    clrf    PORTB
    clrf    PORTD
    return
	
;----------------- Subrutinas ------------------------
	
delay_small:
    movlw   165		    ;valor inicial contador pequeno
    movwf   cont_small
    decfsz  cont_small, 1   ;decrementar por 1 el contador pequenno
    goto    $-1		    ;ejecutar linea anterior
    return
    
inc_A:
    call    delay_small	    ;esta para evitar un rebote
    btfsc   RC0		    ;(el boton esta ciendo precionado) hasta que no se
			    ;suelte el boton no saltara el goto
    goto    $-1
    incf    PORTA	    ;incrementar el conteo de PORTA
    btfsc   PORTA, 4	    ;si el bit 4 es 1 reiniciar el contador
    clrf    PORTA	    ;borrar todo como si fuese un loop al contador
    return

dec_A:
    call    delay_small
    btfsc   RC1
    goto    $-1
    decf    PORTA
    btfsc   PORTA,7 ;si se resta 1 cuando es 0 que se llenen los primeros 4bits
    call    lim_A   ;asegurarme que solo se utilicen los primeros 4 bits
    return
   
lim_A: //si se resta  1 cuando esta en 0 prende todos los bits
    bcf	    PORTA, 4	
    bcf	    PORTA, 5
    bcf	    PORTA, 6
    bcf	    PORTA, 7	;apagar los siguientes bits
    return
    
inc_B:
    call    delay_small
    btfsc   RC2	    
    goto    $-1
    incf    PORTB
    btfsc   PORTB, 4
    clrf    PORTB
    return
    
dec_B:
    call    delay_small
    btfsc   RC3	
    goto    $-1
    decf    PORTB
    btfsc   PORTB, 7
    call    lim_B
    return
    
lim_B: //si se resta  1 cuando esta en 0 prende todos los bits
    bcf	    PORTB, 4	
    bcf	    PORTB, 5
    bcf	    PORTB, 6
    bcf	    PORTB, 7	;apagar los siguientes bits
    return
    
reloj:
    banksel OSCCON
    bsf	    IRCF2   ;1
    bcf	    IRCF1   ;0
    bcf	    IRCF0   ;0
    bsf	    SCS
    return
  
suma:
    movf    PORTB, W ;mover PORTB a W
    addwf   PORTA, W ;la suma de A con B(esta en W) y se guarda en W
    movwf   PORTD   ; el resultado ponerlo en port D
    return
    
ver_suma:
    call    delay_small
    btfsc   RC4	    
    goto    $-1
    call    suma
    return
    
/*
           ,::////;::-.
      /:'///// ``::>/|/
    .',  ||||    `/( e\
-==~-'`-Xm````-mm-' `-_\ 
    */
END