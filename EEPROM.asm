    LIST	P=PIC16F877A
    include <p16F877A.inc>

    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF

PC equ 0x110 ; Program counter (Bank2)
INSTR1 equ 0x111 ; Memory location of MSB of instruction (Bank2)
INSTR2 equ 0x112 ; Memory location of LSB of instruction (Bank2)

    ORG 0x00
    GOTO start


RDINSTR
    BSF     STATUS,RP1;
    BCF     STATUS,RP0; Go to BANK2
    MOVF    PC,W
    INCF    PC,F
    MOVWF   EEADR ; set EEPROM address to read from
    BSF     STATUS,RP0; EECON1 is in BANK3
    BCF     EECON1,EEPGD ; ready to read from EEPROM
    BSF     EECON1,RD ; Data ready now.
    BCF     STATUS, RP0 ; BANK2
    MOVF	EEDATA, W;
    MOVWF   INSTR1;

    MOVF    PC,W
    INCF    PC,F
    MOVWF   EEADR ; set EEPROM address to read from
    BSF     STATUS,RP0; EECON1 is in BANK3
    BCF     EECON1,EEPGD ; ready to read from EEPROM
    BSF     EECON1,RD ; Data ready now.
    BCF     STATUS, RP0 ; BANK2
    MOVF	EEDATA, W;
    MOVWF   INSTR2;
    RETURN

start
    CALL RDINSTR
    GOTO start
    

    end



