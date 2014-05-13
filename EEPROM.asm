    LIST	P=PIC16F877A
    include <p16F877A.inc>
    include "constants.inc"
    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF



    ORG 0x00
    banksel PC
    clrf    PC
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
    btfss   PORTA,ZZ ;get status from PORTA
        bsf   R15,0  ; set C bit
    btfss   PORTA,CC
        bsf   R15,1  ; set Z bit
    return

readInstr ; Read Instruction from EEPROM
    bsf     STATUS,RP1;
    bcf     STATUS,RP0; Go to BANK2
    movf    PC,W
    incf    PC,F
    movwf   EEADR ; set EEPROM address to read from
    bsf     STATUS,RP0; EECON1 is in BANK3
    bcf     EECON1,EEPGD ; ready to read from EEPROM
    bsf     EECON1,RD ; Data ready now.
    bcf     STATUS, RP0 ; BANK2
    movf	EEDATA, W;
    movwf   INSTR1;

    movf    PC,W
    incf    PC,F
    movwf   EEADR ; set EEPROM address to read from
    bsf     STATUS,RP0; EECON1 is in BANK3
    bcf     EECON1,EEPGD ; ready to read from EEPROM
    bsf     EECON1,RD ; Data ready now.
    bcf     STATUS, RP0 ; BANK2
    movf	EEDATA, W;
    movwf   INSTR2;
    RETURN

execInstr ; Execute Instruction
    movf    INSTR1,W
    andlw   0xF0    ; extract upper 4 bits

    xorlw   NOP2    ; xoring will make W=0 and Z=1 if they match
    btfsc   STATUS,Z
    goto    inop2

    xorlw   ADD^NOP2 ;
    btfsc   STATUS,Z
    goto    iadd

    sublw   SUB^ADD ; If it didn't compare before, we want to undo the previous xor
    btfsc   STATUS,Z
    goto    isub

inop2 ; NOP instruction
    goto start

iadd ; ADD instruction

; Write Rc to PORTB<7:4>
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
    movlw   ADD
    movwf   PORTC ; ALU Add
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

isub ; SUB instruction
    movf    INSTR2,W
    andlw   0x0F ;
    call readReg ; get Rc
    movwf    Rc  ; store for later (!!!Actually need to write to IO Port for ALU)

    movf    INSTR2,W
    andlw   0x0F
    call    readReg ; get Rb
    subwf   writeVal ; Rb - Rc !!! use ALU

    movf    INSTR1,W
    andlw   0x0F ; get Ra

    call    writeReg ; Ra = Ra + Rb
    call    writeStatus
    goto start

start
    call    readInstr;
    goto    execInstr;
    goto    start
    end



