    LIST	P=PIC16F877A
    include <p16F877A.inc>
    include "constants.inc"
    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF



    ORG 0x00
    banksel EECON1 ; read from EEPROM instead of Flash
    bcf     EECON1,EEPGD
    banksel EEADR  ; Make sure Program Counter is set to 0
    clrf    EEADR
    banksel ADCON1 ; set PORTA as input
    movlw   0x06
    movwf   ADCON1
    movlw   0xFF
    movwf   TRISA ; PORTA = result from ALU and Z and C
    clrf    TRISB ; PORTB = input to ALU aaaa bbbb
    clrf    TRISC ; PORTC = input to ALU instruction select
    goto start




readReg ; Read register, assuming non-offset reg address is in W already
    addlw   R0  ; offset to actual register locations
    movwf   FSR ; indirect addressing
    movf    INDF,W;
    return

writeReg ; Write to register, assuming non-offset reg address is in W already
    addlw   R0 ; and value to write is in writeVal
    movwf   FSR
    movf    writeVal,W;
    movwf   INDF
    return;

writeStatus ; sets R15, the Status register [- - Z C]
    clrf    R15
    btfsc   PORTA,CC ;get status from PORTA
        bsf   R15,0  ; set C bit
    btfsc   PORTA,ZZ
        bsf   R15,1  ; set Z bit
    return

readInstr ; Read Instruction from EEPROM

    ; Read from current EEADR
    banksel EECON1
    bsf     EECON1,RD ; Data ready now.
    bcf     STATUS, RP0 ; BANK2
    movf	EEDATA, W;
    movwf   INSTR1;

    ; Read from next EEADR
    incf    EEADR,F
    bsf     STATUS, RP0 ; BANK3
    bsf     EECON1,RD ; Data ready now.
    bcf     STATUS, RP0 ; BANK2
    movf	EEDATA, W;
    movwf   INSTR2;
    incf    EEADR,F
    RETURN

execInstr ; Execute Instruction
    movf    INSTR1,W
    andlw   0xF0    ; extract upper 4 bits = kirt_commands
    btfss INSTR1, 7; test MSb if set skip zcommands
    goto zcomands

    ;;now test the one_commands

zcomands ;testing if it's the nop command or if it's rot or ALU
    ;;the kirtcommands are in w

    xorlw NOP2 ; xoring will make W=0 and Z=1 if they match
    btfsc STATUS,Z
    goto start

    xorlw RRL^NOP2 ; :::::: RRL or RRR
    btfsc STATUS,Z
    goto iRotate

    ;do ALU COMMANDS
    xorlw RRL; get the commands back to right ALU commands
    goto    iALU

iRotate
    ;;do rotating commands in ALU;

    goto start;

iALU ; ALU instruction
    banksel PORTC
    movwf   PORTC; put the comand on PORTC for the ALU

; Write Rc to PORTB<7:4>
    banksel INSTR2
    movf    INSTR2,W
    andlw   0x0F ;
    call    readReg ; get Rc
    banksel PORTB
    movwf   PORTB
    swapf   PORTB,F ; PORTB = cccc0000

; Write Rb to PORTB<3:0>
    banksel INSTR2
    swapf   INSTR2,F
    movf    INSTR2,W
    andlw   0x0F
    call    readReg ; get Rb
    banksel PORTB
    iorwf   PORTB,F ; PORTB = ccccbbbb

; Get result from ALU
    movf    PORTA,W

; Write Z,C
    call    writeStatus

; Write to Ra
    banksel INSTR1
    andlw   0x0F
    movwf   writeVal
    movf    INSTR1,W
    andlw   0x0F ; 

    call    writeReg ; Ra = Rb + Rc
    
    goto start


start
    call    readInstr
    goto    execInstr
    goto    start
    end