
;----- Instruction Registers -----------------------------------------------------
PC equ EEADR ; Program counter (Bank2)
INSTR1 equ 0x121 ; Memory location of MSB of instruction (Bank2)
INSTR2 equ 0x122 ; Memory location of LSB of instruction (Bank2)
writeVal    equ 0x123
ALUcmd     equ 0x124

;---- Constants -----------------------------------------------------
ZZ equ H'5'
CC equ H'6'

;---- Instructions -----------------------------------------------------
NOP2 equ B'00000000'; 0000 xxxx xxxx xxxx
ADD equ B'00010000' ; 0001 aaaa bbbb cccc    Z,C     Ra = Rb + Rc
SUB equ B'00100000' ; 0010 aaaa bbbb cccc    Z,C     Ra = Rb ­ Rc
AND equ B'00110000' ; 0011 aaaa bbbb cccc    Z,C     Ra = Rb & Rc
IOR equ B'01000000' ; 0100 aaaa bbbb cccc    Z,C     Ra = Rb | Rc
XOR equ B'01010000' ; 0101 aaaa bbbb cccc    Z,C     Ra = Rb ^ Rc
NOT equ B'01110000' ; 0111 aaaa xxxx bbbb    Z       Ra = ~Rb


RRL equ B'01100000' ; 0110 aaaa 0xxx bbbb    C       Ra = Rb rotated left by 1 thru C
RRR equ B'01100000' ; 0110 aaaa 1xxx bbbb    C       Ra = Rb rotated right by 1 thru C

MOV equ B'10000000' ; 1000 aaaa 1xxx bbbb    Z       Ra = Rb
MOV equ B'10000000' ; 1000 aaaa 0xxx kkkk    Z       Ra = k
LOD equ B'10010000' ; 1001 aaaa 0kkk kkkk    Z       Ra = [k]
LOD equ B'10010000' ; 1001 aaaa 1xxx bbbb    Z       Ra = [Rb(3:1) Rb+1]
STO equ B'10100000' ; 1010 aaaa 0kkk kkkk    Z       [k] = Ra
STO equ B'10100000' ; 1010 aaaa 1xxx bbbb    Z       [Ra(3:1) Ra+1] = Rb
TSC equ B'10110000' ; 1011 aaaa 0xxx xxbb    -       if Ra(b) = 0, PC=PC+2
TSS equ B'10110000' ; 1011 aaaa 1xxx xxbb    -       if Ra(b) = 1, PC=PC+2
JMP equ B'11000000' ; 1100 0kkk kkkk kkkk    -       PC=k<<1 // since instructions are two bytes
JMP equ B'11000000' ; 1100 1xxx xxxx aaaa    -       PC=[Ra(3:1) Ra+1]<<1
JSR equ B'11010000' ; 1101 0kkk kkkk kkkk    -       PC+2->STACK_TOP; PC=k<<1
JSR equ B'11010000' ; 1101 1xxx xxxx aaaa    -       PC+2->STACK_TOP; PC=[Ra(3:1) Ra+1]<<1
RET equ B'11100000' ; 1110 xxxx xxxx xxxx    -       PC <- STACK_TOP





;----- Register Files -----------------------------------------------------
R0 equ 0x70
R1 equ 0x71
R2 equ 0x72
R3 equ 0x73
R4 equ 0x74
R5 equ 0x75
R6 equ 0x76
R7 equ 0x77
R8 equ 0x78
R9 equ 0x79
R10 equ 0x7A
R11 equ 0x7B
R12 equ 0x7C
R13 equ 0x7D
R14 equ 0x7E ; BANK SELECT register
R15 equ 0x7F ; STATUS register [- - Z C] (bank0)