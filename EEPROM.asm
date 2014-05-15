    LIST	P=PIC16F877A
    include <p16F877A.inc>
    include "constants.inc"
    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF



    ORG 0x00
    banksel EECON1 ; read from EEPROM instead of Flash
    bcf     EECON1,EEPGD
    banksel EEADR  ; Make sure Kirt_Program Counter is set to 0
    clrf    EEADR
    banksel ADCON1 ; set PORTA as input
    movlw   0x06
    movwf   ADCON1
    movlw   0xFF
    movwf   TRISA ; PORTA = result from ALU and Z and C
    clrf    TRISB ; PORTB = input to ALU aaaa bbbb
    clrf    TRISC ; PORTC = input to ALU instruction select
    movlw   0x1F
    movwf   sPtr; Set stack pointer to -1 of the top of stack;

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

    ;;now test which of the other commands
    xorlw MOV ; xoring will make W=0 and Z=1 if they match
    btfsc STATUS,Z
    goto iMOV

    xorlw LOD^MOV ; :::::: LOD
    btfsc STATUS,Z
    goto iLOD

    xorlw STO^LOD ; :::::: STO
    btfsc STATUS,Z
    goto iSTO

    xorlw TSC^STO 
    btfsc STATUS,Z
    goto iTSC ;; this will also handle TSS

    xorlw JMP^TSC
    btfsc STATUS,Z
    goto iJMP

    xorlw JSR^JMP
    btfsc STATUS,Z
    goto iJSR

    xorlw RET^JSR
    btfsc STATUS,Z
    goto iRET



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
    btfss INSTR2, 7 ; check which Rotate it is.
    goto iRRL; it's left
    ;else // it's RRR

    goto start;
iRRL

    
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

;;moving/jumping etc. commands
iMOV
    btfss INSTR2, 7 ; check which iMOV it is. 
    goto iMOVk; it's k-type
   
    ;;MOV non-k
    movf  INSTR2, W
    andlw 0x0F; extract bbbb
    call readReg; *B is in W
    movwf  writeVal; writeVal = *B;
    movf INSTR1, W
    andlw 0x0F; extract aaaa
    call writeReg    
    goto start

iMOVk
    movf  INSTR2, W
    andlw 0x0F; extract kkkk
    movwf  writeVal; writeVal = 0000kkkk;
    movf INSTR1, W
    andlw 0x0F; extract aaaa
    call writeReg    
    goto start

iLOD

    btfss INSTR2, 7 ; check which iLOD it is.
    goto iLODk; it's k-type

    goto start

iLODk

    goto start
iSTO

    btfss INSTR2, 7 ; check which iSTO it is.
    goto iSTOk; it's k-type

    goto start

iSTOk
    goto start
iTSC
    btfsc INSTR2, 7 ; check if TSC or TSS
    goto iTSS; it's TSS

    movf    INSTR2, W
    andlw   0x03; extract bb
    movwf   t1; t1 = bb;
    clrf    t2; t2 will be a mask
    incf    t2; t2 = 0x01
    btfsc   t1, 1; check b(1)
    rlf     t2; bit shift left once
    btfsc   t1, 1; check b(1)
    rlf     t2; bit shift left second time
    btfsc   t1, 0; check b(0)
    rlf     t2; bit shift left second time
    ;;t2 should be the right mask now.
    
    movf    INSTR1, W
    andlw   0x0F; extract aaaa
    call    readReg; w = *A

    andwf   t2, w;
    btfss   STATUS, Z;
    goto    start; The bit was =1 so do nothing.//oposite for iTSS
    ;;now make EEADD +=2;
    incf    EEADR;
    incf    EEADR;

    goto    start

iTSS
    movf    INSTR2, W
    andlw   0x03; extract bb
    movwf   t1; t1 = bb;
    clrf    t2; t2 will be a mask
    incf    t2; t2 = 0x01
    btfsc   t1, 1; check b(1)
    rlf     t2; bit shift left once
    btfsc   t1, 1; check b(1)
    rlf     t2; bit shift left second time
    btfsc   t1, 0; check b(0)
    rlf     t2; bit shift left second time
    ;;t2 should be the right mask now.

    movf    INSTR1, W
    andlw   0x0F; extract aaaa
    call    readReg; w = *A

    andwf   t2, w;
    btfsc   STATUS, Z;
    goto    start; The bit was =0 so do nothing.//oposite of iTSC
    ;;now make EEADD +=2;
    incf    EEADR;
    incf    EEADR;

    goto    start
iJMP
    btfss   INSTR1, 4 ; check which iJMP it is.
    goto    iJMPk; it's k-type
    ;;else it's a-type JMP
    movf    INSTR2, W
    andlw   0x0F; extract aaaa
    call    readReg; w = *A
    movwf   t2; t2 = [0x0 *A ] ;
    swapf   t2; t2 = [*A  0x0] ;
    addlw   1;
    call    readReg; w = *(A+1)
    addwf   t2, W; W = [*A *(A+1)];
    movwf   EEADR; EEADR = [*A *(A+1)];
    rlf     EEADR; b/c commmands are 2 bytes.
    goto    start

iJMPk
    movf   INSTR2; w = K;
    movwf   EEADR; = K;
    rlf     EEADR; b/c commmands are 2 bytes.
    goto start
iJSR
    incf    sPtr;
    incf    EEADR;
    incf    EEADR; now EEADR is on the next item for when the function call is done.
    movfw   sPtr;
    movwf   FSR; the location should be at *sPtr
    movfw   EEADR; fill it's with EEADR
    movwf   INDF; (*sPTR) = EEADR;

    btfss INSTR1, 4 ; check which iJSR it is.
    goto iJSRk; it's k-type
    ;else it's a a-type JSR

    movf    INSTR2, W
    andlw   0x0F; extract aaaa
    call    readReg; w = *A
    movwf   t2; t2 = [0x0 *A ] ;
    swapf   t2; t2 = [*A  0x0] ;
    addlw   1;
    call    readReg; w = *(A+1)
    addwf   t2, W; W = [*A *(A+1)];
    movwf   EEADR; EEADR = [*A *(A+1)];
    rlf     EEADR; b/c commmands are 2 bytes.


    goto start

iJSRk
    ;;the stackp movements happened in JSR
    movfw   INSTR2; w = K;
    movwf   EEADR;  EEADR = K;
    rlf     EEADR;  EEADR = K<<1;
  
    goto    start;
iRET
   
   movfw   sPtr;
   movwf   FSR ; indirect addressing
   movf    INDF,W;
   movwf   EEADR;
   decf    sPtr;

    goto start

start
    call    readInstr
    goto    execInstr
    goto    start
    end